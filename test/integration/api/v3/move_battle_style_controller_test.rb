require "test_helper"

class Api::V3::MoveBattleStyleControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeMoveBattleStyle.delete_all

    %w[attack defense support].each do |name|
      PokeMoveBattleStyle.create!(name: name)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/move-battle-style", params: { limit: 1, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 3, payload["count"]
    assert_equal 1, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[id name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/move-battle-style/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/move-battle-style", params: { q: "sup" }

    assert_response :success
    payload = JSON.parse(response.body)
    names = payload["results"].map { |record| record["name"] }

    assert_equal 1, payload["count"]
    assert_equal [ "support" ], names
  end

  test "list supports filter by name" do
    get "/api/v3/move-battle-style", params: { filter: { name: "attack" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "attack", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/move-battle-style", params: { q: "att", filter: { name: "attack" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "attack", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/move-battle-style", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "support", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/move-battle-style", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "show returns move-battle-style payload with standardized keys" do
    style = PokeMoveBattleStyle.find_by!(name: "attack")

    get "/api/v3/move-battle-style/#{style.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[id name url], payload.keys.sort
    assert_equal style.id, payload["id"]
    assert_equal "attack", payload["name"]
    assert_match(%r{/api/v3/move-battle-style/#{style.id}/$}, payload["url"])
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/move-battle-style/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_equal "not_found", payload.dig("error", "code")
    assert_equal "Resource not found", payload.dig("error", "message")
    assert_kind_of Hash, payload.dig("error", "details")
    assert_kind_of String, payload.dig("error", "request_id")
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/move-battle-style", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "fields", payload.dig("error", "details", "param")
    assert_equal [ "unknown" ], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/move-battle-style", params: { include: "anything" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "include", payload.dig("error", "details", "param")
    assert_equal [ "anything" ], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/move-battle-style", params: { sort: "url" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "sort", payload.dig("error", "details", "param")
    assert_equal [ "url" ], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/move-battle-style", params: { filter: { id: "1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "filter", payload.dig("error", "details", "param")
    assert_equal [ "id" ], payload.dig("error", "details", "invalid_values")
  end

  test "list and show accept trailing slash" do
    style = PokeMoveBattleStyle.find_by!(name: "attack")

    get "/api/v3/move-battle-style/"
    assert_response :success

    get "/api/v3/move-battle-style/#{style.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/move-battle-style", params: { limit: 2, offset: 0, q: "sup" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/move-battle-style", params: { limit: 2, offset: 0, q: "sup" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    style = PokeMoveBattleStyle.find_by!(name: "attack")

    get "/api/v3/move-battle-style/#{style.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/move-battle-style/#{style.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "list etag varies by sort parameter" do
    get "/api/v3/move-battle-style", params: { q: "a" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/move-battle-style", params: { q: "a", sort: "-name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    style = PokeMoveBattleStyle.find_by!(name: "attack")

    get "/api/v3/move-battle-style/#{style.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/move-battle-style/#{style.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
