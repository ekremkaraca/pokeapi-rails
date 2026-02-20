require "test_helper"

class Api::V3::LanguageControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeLanguage.delete_all

    [
      { name: "en", iso639: "en", iso3166: "us", official: true, sort_order: 1 },
      { name: "ja", iso639: "ja", iso3166: "jp", official: true, sort_order: 2 },
      { name: "roomaji", iso639: "ja-hrkt", iso3166: nil, official: false, sort_order: 3 }
    ].each do |attrs|
      PokeLanguage.create!(attrs)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/language", params: { limit: 2, offset: 0 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 3, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_nil payload["previous"]
    assert_equal %w[id name official url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/language/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/language", params: { q: "oo" }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "roomaji", payload.dig("results", 0, "name")
  end

  test "list supports filter by name" do
    get "/api/v3/language", params: { filter: { name: "en" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "en", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/language", params: { q: "room", filter: { name: "roomaji" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "roomaji", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/language", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "roomaji", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/language", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "show returns language payload with standardized keys" do
    language = PokeLanguage.find_by!(name: "en")

    get "/api/v3/language/#{language.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[id iso3166 iso639 name official sort_order url], payload.keys.sort
    assert_equal language.id, payload["id"]
    assert_equal "en", payload["name"]
    assert_equal "en", payload["iso639"]
    assert_equal "us", payload["iso3166"]
    assert_match(%r{/api/v3/language/#{language.id}/$}, payload["url"])
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/language/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_equal "not_found", payload.dig("error", "code")
    assert_equal "Resource not found", payload.dig("error", "message")
    assert_kind_of Hash, payload.dig("error", "details")
    assert_kind_of String, payload.dig("error", "request_id")
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/language", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "fields", payload.dig("error", "details", "param")
    assert_equal ["unknown"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/language", params: { include: "anything" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "include", payload.dig("error", "details", "param")
    assert_equal ["anything"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/language", params: { sort: "official" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "sort", payload.dig("error", "details", "param")
    assert_equal ["official"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/language", params: { filter: { iso639: "en" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "filter", payload.dig("error", "details", "param")
    assert_equal ["iso639"], payload.dig("error", "details", "invalid_values")
  end

  test "list and show accept trailing slash" do
    language = PokeLanguage.find_by!(name: "en")

    get "/api/v3/language/"
    assert_response :success

    get "/api/v3/language/#{language.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/language", params: { limit: 2, offset: 0, q: "room" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/language", params: { limit: 2, offset: 0, q: "room" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    language = PokeLanguage.find_by!(name: "en")

    get "/api/v3/language/#{language.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/language/#{language.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "show etag varies by fields parameter" do
    language = PokeLanguage.find_by!(name: "en")

    get "/api/v3/language/#{language.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/language/#{language.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
