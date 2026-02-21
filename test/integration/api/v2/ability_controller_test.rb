require "test_helper"

class Api::V2::AbilityControllerTest < ActionDispatch::IntegrationTest
  setup do
    Ability.delete_all

    [
      { name: "stench", is_main_series: true },
      { name: "drizzle", is_main_series: true },
      { name: "swift-swim", is_main_series: true },
      { name: "chlorophyll", is_main_series: true },
      { name: "cloud-nine", is_main_series: true }
    ].each do |attrs|
      Ability.create!(attrs)
    end

    25.times do |idx|
      Ability.create!(name: "ability-#{idx + 1}", is_main_series: (idx % 2).zero?)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/ability", params: { limit: 5, offset: 2 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 30, payload["count"]
    assert_equal 5, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/ability/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/ability/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/ability", params: { q: "swim" }

    assert_response :success
    payload = JSON.parse(response.body)
    names = payload["results"].map { |record| record["name"] }

    assert_equal 1, payload["count"]
    assert_equal [ "swift-swim" ], names
  end

  test "show supports retrieval by id and name" do
    ability = Ability.find_by!(name: "stench")

    get "/api/v2/ability/#{ability.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[effect_changes effect_entries flavor_text_entries generation id is_main_series name names pokemon], payload.keys.sort
    assert_equal "stench", payload["name"]
    assert_equal true, payload["is_main_series"]
    assert_nil payload["generation"]
    assert_equal [], payload["effect_changes"]
    assert_equal [], payload["effect_entries"]
    assert_equal [], payload["flavor_text_entries"]
    assert_equal [], payload["names"]
    assert_equal [], payload["pokemon"]

    get "/api/v2/ability/STENCH"
    assert_response :success
  end

  test "list and show accept trailing slash" do
    ability = Ability.find_by!(name: "stench")

    get "/api/v2/ability/"
    assert_response :success

    get "/api/v2/ability/#{ability.id}/"
    assert_response :success
  end

  test "responds with json even when html format is requested" do
    get "/api/v2/ability.html"

    assert_response :success
    assert_equal "application/json; charset=utf-8", response.headers["Content-Type"]
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/ability/%2A%2A"

    assert_response :not_found
  end

  test "show orders pokemon entries by pokemon id before slot" do
    ability = Ability.find_by!(name: "stench")
    pokemon_a = Pokemon.create!(name: "alpha-mon")
    pokemon_b = Pokemon.create!(name: "beta-mon")

    PokePokemonAbility.create!(pokemon_id: pokemon_a.id, ability_id: ability.id, slot: 3, is_hidden: true)
    PokePokemonAbility.create!(pokemon_id: pokemon_b.id, ability_id: ability.id, slot: 1, is_hidden: false)

    get "/api/v2/ability/#{ability.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal [ "alpha-mon", "beta-mon" ], payload["pokemon"].map { |row| row.dig("pokemon", "name") }
  end
end
