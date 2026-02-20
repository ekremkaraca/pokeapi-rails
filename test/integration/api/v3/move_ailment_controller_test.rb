require "test_helper"

class Api::V3::MoveAilmentControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeMoveAilment.delete_all

    [
      { id: -1, name: "unknown" },
      { id: 0, name: "none" },
      { id: 1, name: "paralysis" },
      { id: 2, name: "sleep" },
      { id: 3, name: "freeze" }
    ].each do |attrs|
      PokeMoveAilment.create!(attrs)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/move-ailment", params: { limit: 3, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 3, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[id name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/move-ailment/[-]?\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/move-ailment", params: { q: "s" }

    assert_response :success
    payload = JSON.parse(response.body)
    names = payload["results"].map { |record| record["name"] }

    assert_equal 2, payload["count"]
    assert_includes names, "sleep"
    assert_includes names, "paralysis"
  end

  test "list supports filter by name" do
    get "/api/v3/move-ailment", params: { filter: { name: "none" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "none", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/move-ailment", params: { q: "al", filter: { name: "paralysis" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "paralysis", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/move-ailment", params: { sort: "-id" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 3, payload.fetch("results").first.fetch("id")
  end

  test "list supports fields filter" do
    get "/api/v3/move-ailment", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "show returns move-ailment payload with standardized keys for signed id" do
    get "/api/v3/move-ailment/-1"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[id name url], payload.keys.sort
    assert_equal(-1, payload["id"])
    assert_equal "unknown", payload["name"]
    assert_match(%r{/api/v3/move-ailment/-1/$}, payload["url"])
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/move-ailment/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_equal "not_found", payload.dig("error", "code")
    assert_equal "Resource not found", payload.dig("error", "message")
    assert_kind_of Hash, payload.dig("error", "details")
    assert_kind_of String, payload.dig("error", "request_id")
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/move-ailment", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "fields", payload.dig("error", "details", "param")
    assert_equal [ "unknown" ], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/move-ailment", params: { include: "anything" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "include", payload.dig("error", "details", "param")
    assert_equal [ "anything" ], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/move-ailment", params: { sort: "url" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "sort", payload.dig("error", "details", "param")
    assert_equal [ "url" ], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/move-ailment", params: { filter: { id: "-1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "filter", payload.dig("error", "details", "param")
    assert_equal [ "id" ], payload.dig("error", "details", "invalid_values")
  end

  test "list and show accept trailing slash" do
    get "/api/v3/move-ailment/"
    assert_response :success

    get "/api/v3/move-ailment/-1/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/move-ailment", params: { limit: 2, offset: 0, q: "s" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/move-ailment", params: { limit: 2, offset: 0, q: "s" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    get "/api/v3/move-ailment/-1"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/move-ailment/-1", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "list etag varies by sort parameter" do
    get "/api/v3/move-ailment", params: { q: "s" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/move-ailment", params: { q: "s", sort: "-id" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    get "/api/v3/move-ailment/-1", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/move-ailment/-1", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
