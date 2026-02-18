require "test_helper"

class Api::V2::PokemonHabitatControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokePokemonHabitat.delete_all

    %w[cave forest grassland mountain rare].each do |name|
      PokePokemonHabitat.create!(name: name)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/pokemon-habitat", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/pokemon-habitat/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/pokemon-habitat/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/pokemon-habitat", params: { q: "ra" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 2, payload["count"]
  end

  test "show supports retrieval by id and name" do
    habitat = PokePokemonHabitat.find_by!(name: "cave")

    get "/api/v2/pokemon-habitat/#{habitat.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal habitat.id, payload["id"]
    assert_equal "cave", payload["name"]

    get "/api/v2/pokemon-habitat/CAVE"
    assert_response :success
  end

  test "list and show accept trailing slash" do
    habitat = PokePokemonHabitat.find_by!(name: "cave")

    get "/api/v2/pokemon-habitat/"
    assert_response :success

    get "/api/v2/pokemon-habitat/#{habitat.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/pokemon-habitat/%2A%2A"

    assert_response :not_found
  end
end
