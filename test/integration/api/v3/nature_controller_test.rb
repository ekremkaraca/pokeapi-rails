require "test_helper"

class Api::V3::NatureControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeNature.delete_all

    [
      { name: "hardy", decreased_stat_id: 2, increased_stat_id: 2, hates_flavor_id: 1, likes_flavor_id: 1, game_index: 0 },
      { name: "bold", decreased_stat_id: 2, increased_stat_id: 3, hates_flavor_id: 1, likes_flavor_id: 2, game_index: 1 },
      { name: "modest", decreased_stat_id: 2, increased_stat_id: 4, hates_flavor_id: 1, likes_flavor_id: 3, game_index: 2 },
      { name: "calm", decreased_stat_id: 2, increased_stat_id: 5, hates_flavor_id: 1, likes_flavor_id: 4, game_index: 3 },
      { name: "timid", decreased_stat_id: 2, increased_stat_id: 6, hates_flavor_id: 1, likes_flavor_id: 5, game_index: 4 }
    ].each do |attrs|
      PokeNature.create!(attrs)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/nature", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[id name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/nature/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/nature", params: { q: "mod" }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal ["modest"], payload.fetch("results").map { |record| record["name"] }
  end

  test "list supports filter by name" do
    get "/api/v3/nature", params: { filter: { name: "hardy" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "hardy", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/nature", params: { q: "mod", filter: { name: "modest" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "modest", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/nature", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "timid", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/nature", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "show returns nature payload with standardized keys" do
    nature = PokeNature.find_by!(name: "hardy")

    get "/api/v3/nature/#{nature.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[decreased_stat_id game_index hates_flavor_id id increased_stat_id likes_flavor_id name url], payload.keys.sort
    assert_equal nature.id, payload["id"]
    assert_equal "hardy", payload["name"]
    assert_equal 2, payload["decreased_stat_id"]
    assert_match(%r{/api/v3/nature/#{nature.id}/$}, payload["url"])
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/nature/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_equal "not_found", payload.dig("error", "code")
    assert_equal "Resource not found", payload.dig("error", "message")
    assert_kind_of Hash, payload.dig("error", "details")
    assert_kind_of String, payload.dig("error", "request_id")
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/nature", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "fields", payload.dig("error", "details", "param")
    assert_equal ["unknown"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/nature", params: { include: "unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "include", payload.dig("error", "details", "param")
    assert_equal ["unknown"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/nature", params: { sort: "game_index" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "sort", payload.dig("error", "details", "param")
    assert_equal ["game_index"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/nature", params: { filter: { id: "1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "filter", payload.dig("error", "details", "param")
    assert_equal ["id"], payload.dig("error", "details", "invalid_values")
  end

  test "list and show accept trailing slash" do
    nature = PokeNature.find_by!(name: "hardy")

    get "/api/v3/nature/"
    assert_response :success

    get "/api/v3/nature/#{nature.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/nature", params: { limit: 2, offset: 0, q: "mod" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/nature", params: { limit: 2, offset: 0, q: "mod" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    nature = PokeNature.find_by!(name: "hardy")

    get "/api/v3/nature/#{nature.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/nature/#{nature.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "list etag varies by sort parameter" do
    get "/api/v3/nature", params: { limit: 2, sort: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/nature", params: { limit: 2, sort: "-name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    nature = PokeNature.find_by!(name: "hardy")

    get "/api/v3/nature/#{nature.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/nature/#{nature.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
