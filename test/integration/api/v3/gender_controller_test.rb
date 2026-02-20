require "test_helper"

class Api::V3::GenderControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeGender.delete_all

    %w[female male genderless].each do |name|
      PokeGender.create!(name: name)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/gender", params: { limit: 2, offset: 0 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 3, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_nil payload["previous"]
    assert_equal %w[id name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/gender/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/gender", params: { q: "male" }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 2, payload["count"]
  end

  test "list supports filter by name" do
    get "/api/v3/gender", params: { filter: { name: "female" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "female", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/gender", params: { q: "male", filter: { name: "male" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "male", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/gender", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "male", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/gender", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "show returns gender payload with standardized keys" do
    gender = PokeGender.find_by!(name: "female")

    get "/api/v3/gender/#{gender.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[id name url], payload.keys.sort
    assert_equal gender.id, payload["id"]
    assert_equal "female", payload["name"]
    assert_match(%r{/api/v3/gender/#{gender.id}/$}, payload["url"])
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/gender/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_equal "not_found", payload.dig("error", "code")
    assert_equal "Resource not found", payload.dig("error", "message")
    assert_kind_of Hash, payload.dig("error", "details")
    assert_kind_of String, payload.dig("error", "request_id")
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/gender", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "fields", payload.dig("error", "details", "param")
    assert_equal ["unknown"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/gender", params: { include: "unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "include", payload.dig("error", "details", "param")
    assert_equal ["unknown"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/gender", params: { sort: "created_at" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "sort", payload.dig("error", "details", "param")
    assert_equal ["created_at"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/gender", params: { filter: { id: "1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "filter", payload.dig("error", "details", "param")
    assert_equal ["id"], payload.dig("error", "details", "invalid_values")
  end

  test "list and show accept trailing slash" do
    gender = PokeGender.find_by!(name: "female")

    get "/api/v3/gender/"
    assert_response :success

    get "/api/v3/gender/#{gender.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/gender", params: { limit: 2, offset: 0, q: "male" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/gender", params: { limit: 2, offset: 0, q: "male" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    gender = PokeGender.find_by!(name: "female")

    get "/api/v3/gender/#{gender.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/gender/#{gender.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "list etag varies by sort parameter" do
    get "/api/v3/gender", params: { limit: 2, sort: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/gender", params: { limit: 2, sort: "-name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    gender = PokeGender.find_by!(name: "female")

    get "/api/v3/gender/#{gender.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/gender/#{gender.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
