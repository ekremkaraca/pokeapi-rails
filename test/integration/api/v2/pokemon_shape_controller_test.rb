require "test_helper"

class Api::V2::PokemonShapeControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokePokemonShape.delete_all

    %w[ball squiggle fish arms blob].each do |name|
      PokePokemonShape.create!(name: name)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/pokemon-shape", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/pokemon-shape/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/pokemon-shape/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/pokemon-shape", params: { q: "bl" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 1, payload["count"]
    assert_equal ["blob"], payload["results"].map { |record| record["name"] }
  end

  test "show supports retrieval by id and name" do
    shape = PokePokemonShape.find_by!(name: "ball")

    get "/api/v2/pokemon-shape/#{shape.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal shape.id, payload["id"]
    assert_equal "ball", payload["name"]

    get "/api/v2/pokemon-shape/BALL"
    assert_response :success
  end

  test "list and show accept trailing slash" do
    shape = PokePokemonShape.find_by!(name: "ball")

    get "/api/v2/pokemon-shape/"
    assert_response :success

    get "/api/v2/pokemon-shape/#{shape.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/pokemon-shape/%2A%2A"

    assert_response :not_found
  end
end
