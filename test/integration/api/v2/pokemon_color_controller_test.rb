require "test_helper"

class Api::V2::PokemonColorControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokePokemonColor.delete_all

    %w[black blue brown gray green].each do |name|
      PokePokemonColor.create!(name: name)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/pokemon-color", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/pokemon-color/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/pokemon-color/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/pokemon-color", params: { q: "bl" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 2, payload["count"]
    assert_equal %w[black blue], payload["results"].map { |record| record["name"] }
  end

  test "show supports retrieval by id and name" do
    color = PokePokemonColor.find_by!(name: "black")

    get "/api/v2/pokemon-color/#{color.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal color.id, payload["id"]
    assert_equal "black", payload["name"]

    get "/api/v2/pokemon-color/BLACK"
    assert_response :success
  end

  test "list and show accept trailing slash" do
    color = PokePokemonColor.find_by!(name: "black")

    get "/api/v2/pokemon-color/"
    assert_response :success

    get "/api/v2/pokemon-color/#{color.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/pokemon-color/%2A%2A"

    assert_response :not_found
  end
end
