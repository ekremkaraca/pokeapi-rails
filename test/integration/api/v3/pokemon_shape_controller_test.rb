require "test_helper"

class Api::V3::PokemonShapeControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokePokemonShape.delete_all
    %w[ball squiggle fish arms blob].each { |name| PokePokemonShape.create!(name: name) }
  end

  test "list returns paginated data and supports q/filter/sort/fields" do
    get "/api/v3/pokemon-shape", params: { limit: 2, offset: 0, q: "bl", filter: { name: "blob" }, sort: "-name", fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 1, payload["count"]
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "show returns standardized payload" do
    shape = PokePokemonShape.find_by!(name: "ball")
    get "/api/v3/pokemon-shape/#{shape.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[id name url], payload.keys.sort
  end

  test "invalid token and invalid params return standardized errors" do
    get "/api/v3/pokemon-shape/not-a-number"
    assert_response :not_found

    get "/api/v3/pokemon-shape", params: { fields: "name,unknown" }
    assert_response :bad_request
    get "/api/v3/pokemon-shape", params: { include: "anything" }
    assert_response :bad_request
    get "/api/v3/pokemon-shape", params: { sort: "url" }
    assert_response :bad_request
    get "/api/v3/pokemon-shape", params: { filter: { id: "1" } }
    assert_response :bad_request
  end

  test "trailing slash and conditional get are supported" do
    shape = PokePokemonShape.find_by!(name: "ball")

    get "/api/v3/pokemon-shape/"
    assert_response :success
    get "/api/v3/pokemon-shape/#{shape.id}/"
    assert_response :success

    get "/api/v3/pokemon-shape", params: { q: "ball" }
    etag = response.headers["ETag"]
    get "/api/v3/pokemon-shape", params: { q: "ball" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
  end
end
