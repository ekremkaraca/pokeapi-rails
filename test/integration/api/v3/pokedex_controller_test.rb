require "test_helper"

class Api::V3::PokedexControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokePokedex.delete_all

    [
      { name: "national", is_main_series: true, region_id: nil },
      { name: "kanto", is_main_series: true, region_id: 1 },
      { name: "original-johto", is_main_series: true, region_id: 2 },
      { name: "conquest-gallery", is_main_series: false, region_id: nil }
    ].each { |attrs| PokePokedex.create!(attrs) }
  end

  test "list returns paginated summary data with standardized keys" do
    get "/api/v3/pokedex", params: { limit: 2, offset: 0 }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 4, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_nil payload["previous"]
    assert_equal %w[id is_main_series name region_id url], payload["results"].first.keys.sort
  end

  test "list supports q filter" do
    get "/api/v3/pokedex", params: { q: "johto" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 1, payload["count"]
    assert_equal "original-johto", payload.dig("results", 0, "name")
  end

  test "list supports filter by name" do
    get "/api/v3/pokedex", params: { filter: { name: "kanto" } }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 1, payload["count"]
    assert_equal "kanto", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/pokedex", params: { q: "k", filter: { name: "kanto" } }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 1, payload["count"]
    assert_equal "kanto", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/pokedex", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "original-johto", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/pokedex", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "show returns standardized payload" do
    pokedex = PokePokedex.find_by!(name: "national")

    get "/api/v3/pokedex/#{pokedex.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[id is_main_series name region_id url], payload.keys.sort
    assert_equal pokedex.id, payload["id"]
    assert_equal "national", payload["name"]
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/pokedex/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)
    assert_equal "not_found", payload.dig("error", "code")
    assert_equal "Resource not found", payload.dig("error", "message")
    assert_kind_of Hash, payload.dig("error", "details")
    assert_kind_of String, payload.dig("error", "request_id")
  end

  test "returns bad request for invalid fields/include/sort/filter parameters" do
    get "/api/v3/pokedex", params: { fields: "name,unknown" }
    assert_response :bad_request

    get "/api/v3/pokedex", params: { include: "anything" }
    assert_response :bad_request

    get "/api/v3/pokedex", params: { sort: "url" }
    assert_response :bad_request

    get "/api/v3/pokedex", params: { filter: { is_main_series: "true" } }
    assert_response :bad_request
  end

  test "list and show accept trailing slash" do
    pokedex = PokePokedex.find_by!(name: "national")

    get "/api/v3/pokedex/"
    assert_response :success

    get "/api/v3/pokedex/#{pokedex.id}/"
    assert_response :success
  end

  test "list and show support conditional get with etag" do
    pokedex = PokePokedex.find_by!(name: "national")

    get "/api/v3/pokedex", params: { q: "nat" }
    assert_response :success
    list_etag = response.headers["ETag"]
    assert list_etag.present?
    get "/api/v3/pokedex", params: { q: "nat" }, headers: { "If-None-Match" => list_etag }
    assert_response :not_modified

    get "/api/v3/pokedex/#{pokedex.id}"
    assert_response :success
    show_etag = response.headers["ETag"]
    assert show_etag.present?
    get "/api/v3/pokedex/#{pokedex.id}", headers: { "If-None-Match" => show_etag }
    assert_response :not_modified
  end
end
