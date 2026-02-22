require "test_helper"

class Api::V3::GrowthRateControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeGrowthRate.delete_all

    [
      { name: "slow", formula: "\\frac{5x^3}{4}" },
      { name: "medium", formula: "x^3" },
      { name: "fast", formula: "\\frac{4x^3}{5}" },
      { name: "medium-slow", formula: "\\frac{6x^3}{5}" },
      { name: "erratic", formula: "varies" }
    ].each do |attrs|
      PokeGrowthRate.create!(attrs)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/growth-rate", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[id name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/growth-rate/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/growth-rate", params: { q: "slow" }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 2, payload["count"]
  end

  test "list supports filter by name" do
    get "/api/v3/growth-rate", params: { filter: { name: "fast" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "fast", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/growth-rate", params: { q: "slow", filter: { name: "medium-slow" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "medium-slow", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/growth-rate", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "slow", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/growth-rate", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "show returns growth rate payload with standardized keys" do
    growth_rate = PokeGrowthRate.find_by!(name: "slow")

    get "/api/v3/growth-rate/#{growth_rate.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[formula id name url], payload.keys.sort
    assert_equal growth_rate.id, payload["id"]
    assert_equal "slow", payload["name"]
    assert_equal "\\frac{5x^3}{4}", payload["formula"]
    assert_match(%r{/api/v3/growth-rate/#{growth_rate.id}/$}, payload["url"])
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/growth-rate/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_not_found_error_envelope(payload)
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/growth-rate", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "fields", invalid_values: [ "unknown" ])
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/growth-rate", params: { include: "unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "include", invalid_values: [ "unknown" ])
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/growth-rate", params: { sort: "formula" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "sort", invalid_values: [ "formula" ])
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/growth-rate", params: { filter: { id: "1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "filter", invalid_values: [ "id" ])
  end

  test "list and show accept trailing slash" do
    growth_rate = PokeGrowthRate.find_by!(name: "slow")

    get "/api/v3/growth-rate/"
    assert_response :success

    get "/api/v3/growth-rate/#{growth_rate.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/growth-rate", params: { limit: 2, offset: 0, q: "slow" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/growth-rate", params: { limit: 2, offset: 0, q: "slow" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    growth_rate = PokeGrowthRate.find_by!(name: "slow")

    get "/api/v3/growth-rate/#{growth_rate.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/growth-rate/#{growth_rate.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "list etag varies by sort parameter" do
    get "/api/v3/growth-rate", params: { limit: 2, sort: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/growth-rate", params: { limit: 2, sort: "-name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    growth_rate = PokeGrowthRate.find_by!(name: "slow")

    get "/api/v3/growth-rate/#{growth_rate.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/growth-rate/#{growth_rate.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
