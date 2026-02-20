require "test_helper"

class Api::V2::PokedexControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokePokedex.delete_all

    [
      { name: "national", is_main_series: true },
      { name: "kanto", is_main_series: true },
      { name: "original-johto", is_main_series: true },
      { name: "hoenn", is_main_series: true },
      { name: "conquest-gallery", is_main_series: false }
    ].each do |attrs|
      PokePokedex.create!(attrs)
    end

    25.times do |idx|
      PokePokedex.create!(name: "pokedex-#{idx + 1}", is_main_series: (idx % 2).zero?)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/pokedex", params: { limit: 5, offset: 2 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 30, payload["count"]
    assert_equal 5, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/pokedex/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/pokedex/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/pokedex", params: { q: "johto" }

    assert_response :success
    payload = JSON.parse(response.body)
    names = payload["results"].map { |record| record["name"] }

    assert_equal 1, payload["count"]
    assert_equal [ "original-johto" ], names
  end

  test "show supports retrieval by id and name" do
    pokedex = PokePokedex.find_by!(name: "national")

    get "/api/v2/pokedex/#{pokedex.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal pokedex.id, payload["id"]
    assert_equal "national", payload["name"]
    assert_equal true, payload["is_main_series"]

    get "/api/v2/pokedex/NATIONAL"
    assert_response :success
  end

  test "list and show accept trailing slash" do
    pokedex = PokePokedex.find_by!(name: "national")

    get "/api/v2/pokedex/"
    assert_response :success

    get "/api/v2/pokedex/#{pokedex.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/pokedex/%2A%2A"

    assert_response :not_found
  end
end
