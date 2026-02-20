require "test_helper"

class Api::V3::PokemonHabitatControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokePokemonHabitat.delete_all
    %w[cave forest grassland mountain rare].each { |name| PokePokemonHabitat.create!(name: name) }
  end

  test "list returns paginated data and supports q/filter/sort/fields" do
    get "/api/v3/pokemon-habitat", params: { limit: 2, offset: 0, q: "ra", filter: { name: "rare" }, sort: "-name", fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 1, payload["count"]
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "show returns standardized payload" do
    habitat = PokePokemonHabitat.find_by!(name: "cave")
    get "/api/v3/pokemon-habitat/#{habitat.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[id name url], payload.keys.sort
  end

  test "invalid token and invalid params return standardized errors" do
    get "/api/v3/pokemon-habitat/not-a-number"
    assert_response :not_found

    get "/api/v3/pokemon-habitat", params: { fields: "name,unknown" }
    assert_response :bad_request
    get "/api/v3/pokemon-habitat", params: { include: "anything" }
    assert_response :bad_request
    get "/api/v3/pokemon-habitat", params: { sort: "url" }
    assert_response :bad_request
    get "/api/v3/pokemon-habitat", params: { filter: { id: "1" } }
    assert_response :bad_request
  end

  test "trailing slash and conditional get are supported" do
    habitat = PokePokemonHabitat.find_by!(name: "cave")

    get "/api/v3/pokemon-habitat/"
    assert_response :success
    get "/api/v3/pokemon-habitat/#{habitat.id}/"
    assert_response :success

    get "/api/v3/pokemon-habitat", params: { q: "cave" }
    etag = response.headers["ETag"]
    get "/api/v3/pokemon-habitat", params: { q: "cave" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
  end
end
