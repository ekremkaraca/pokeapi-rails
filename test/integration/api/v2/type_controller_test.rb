require "test_helper"

class Api::V2::TypeControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeType.delete_all

    %w[normal fighting flying poison psychic].each do |name|
      PokeType.create!(name: name)
    end

    25.times do |idx|
      PokeType.create!(name: "type-#{idx + 1}")
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/type", params: { limit: 5, offset: 2 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 30, payload["count"]
    assert_equal 5, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/type/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/type/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/type", params: { q: "psy" }

    assert_response :success
    payload = JSON.parse(response.body)
    names = payload["results"].map { |record| record["name"] }

    assert_equal 1, payload["count"]
    assert_equal [ "psychic" ], names
  end

  test "show supports retrieval by id and name" do
    type = PokeType.find_by!(name: "normal")

    get "/api/v2/type/#{type.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[damage_relations game_indices generation id move_damage_class moves name names past_damage_relations pokemon sprites], payload.keys.sort
    assert_equal "normal", payload["name"]
    assert_equal type.id, payload["id"]
    assert_equal %w[double_damage_from double_damage_to half_damage_from half_damage_to no_damage_from no_damage_to], payload["damage_relations"].keys.sort
    assert_equal [], payload["game_indices"]
    assert_nil payload["generation"]
    assert_nil payload["move_damage_class"]
    assert_equal [], payload["moves"]
    assert_equal [], payload["names"]
    assert_equal [], payload["past_damage_relations"]
    assert_equal [], payload["pokemon"]
    assert_equal %w[generation-iii generation-iv generation-ix generation-v generation-vi generation-vii generation-viii], payload["sprites"].keys.sort
    assert_equal %w[colosseum emerald firered-leafgreen ruby-sapphire xd], payload["sprites"]["generation-iii"].keys.sort
    assert_equal %w[omega-ruby-alpha-sapphire x-y], payload["sprites"]["generation-vi"].keys.sort
    assert_equal %w[brilliant-diamond-shining-pearl legends-arceus sword-shield], payload["sprites"]["generation-viii"].keys.sort
    assert_nil payload["sprites"]["generation-viii"]["brilliant-diamond-shining-pearl"]["name_icon"]

    get "/api/v2/type/NORMAL"
    assert_response :success
  end

  test "list and show accept trailing slash" do
    type = PokeType.find_by!(name: "normal")

    get "/api/v2/type/"
    assert_response :success

    get "/api/v2/type/#{type.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/type/%2A%2A"

    assert_response :not_found
  end

  test "show orders pokemon entries by pokemon id before slot" do
    type = PokeType.find_by!(name: "normal")
    pokemon_a = Pokemon.create!(name: "alpha-type-mon")
    pokemon_b = Pokemon.create!(name: "beta-type-mon")

    PokePokemonType.create!(pokemon_id: pokemon_a.id, type_id: type.id, slot: 2)
    PokePokemonType.create!(pokemon_id: pokemon_b.id, type_id: type.id, slot: 1)

    get "/api/v2/type/#{type.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal [ "alpha-type-mon", "beta-type-mon" ], payload["pokemon"].map { |row| row.dig("pokemon", "name") }
  end
end
