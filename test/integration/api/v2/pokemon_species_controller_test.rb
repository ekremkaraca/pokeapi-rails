require "test_helper"

class Api::V2::PokemonSpeciesControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokePokemonSpecies.delete_all

    [
      { name: "bulbasaur", generation_id: 1, evolves_from_species_id: nil, evolution_chain_id: 1, color_id: 5, shape_id: 8, habitat_id: 3, gender_rate: 1, capture_rate: 45, base_happiness: 70, is_baby: false, hatch_counter: 20, has_gender_differences: false, growth_rate_id: 4, forms_switchable: false, is_legendary: false, is_mythical: false, sort_order: 1, conquest_order: nil },
      { name: "ivysaur", generation_id: 1, evolves_from_species_id: 1, evolution_chain_id: 1, color_id: 5, shape_id: 8, habitat_id: 3, gender_rate: 1, capture_rate: 45, base_happiness: 70, is_baby: false, hatch_counter: 20, has_gender_differences: false, growth_rate_id: 4, forms_switchable: false, is_legendary: false, is_mythical: false, sort_order: 2, conquest_order: nil },
      { name: "venusaur", generation_id: 1, evolves_from_species_id: 2, evolution_chain_id: 1, color_id: 5, shape_id: 8, habitat_id: 3, gender_rate: 1, capture_rate: 45, base_happiness: 70, is_baby: false, hatch_counter: 20, has_gender_differences: false, growth_rate_id: 4, forms_switchable: true, is_legendary: false, is_mythical: false, sort_order: 3, conquest_order: nil },
      { name: "mew", generation_id: 1, evolves_from_species_id: nil, evolution_chain_id: 133, color_id: 6, shape_id: 6, habitat_id: 8, gender_rate: -1, capture_rate: 45, base_happiness: 100, is_baby: false, hatch_counter: 120, has_gender_differences: false, growth_rate_id: 1, forms_switchable: false, is_legendary: false, is_mythical: true, sort_order: 151, conquest_order: nil },
      { name: "lugia", generation_id: 2, evolves_from_species_id: nil, evolution_chain_id: 246, color_id: 9, shape_id: 9, habitat_id: 8, gender_rate: -1, capture_rate: 3, base_happiness: 0, is_baby: false, hatch_counter: 120, has_gender_differences: false, growth_rate_id: 1, forms_switchable: false, is_legendary: true, is_mythical: false, sort_order: 249, conquest_order: nil }
    ].each do |attrs|
      PokePokemonSpecies.create!(attrs)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/pokemon-species", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/pokemon-species/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/pokemon-species/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/pokemon-species", params: { q: "saur" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 3, payload["count"]
  end

  test "show supports retrieval by id and name" do
    species = PokePokemonSpecies.find_by!(name: "lugia")

    get "/api/v2/pokemon-species/#{species.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[base_happiness capture_rate color egg_groups evolution_chain evolves_from_species flavor_text_entries form_descriptions forms_switchable gender_rate genera generation growth_rate habitat has_gender_differences hatch_counter id is_baby is_legendary is_mythical name names order pal_park_encounters pokedex_numbers shape varieties], payload.keys.sort
    assert_equal species.id, payload["id"]
    assert_equal "lugia", payload["name"]
    assert_nil payload["generation"]
    assert_equal true, payload["is_legendary"]
    assert_equal false, payload["is_mythical"]
    assert_equal -1, payload["gender_rate"]
    assert_equal species.sort_order, payload["order"]
    assert_equal [], payload["egg_groups"]
    assert_equal [], payload["flavor_text_entries"]
    assert_equal [], payload["form_descriptions"]
    assert_equal [], payload["genera"]
    assert_equal [], payload["names"]
    assert_equal [], payload["pal_park_encounters"]
    assert_equal [], payload["pokedex_numbers"]
    assert_equal [], payload["varieties"]
    assert_nil payload["color"]
    assert_nil payload["growth_rate"]
    assert_nil payload["habitat"]
    assert_nil payload["shape"]

    get "/api/v2/pokemon-species/LUGIA"
    assert_response :success
  end

  test "list and show accept trailing slash" do
    species = PokePokemonSpecies.find_by!(name: "lugia")

    get "/api/v2/pokemon-species/"
    assert_response :success

    get "/api/v2/pokemon-species/#{species.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/pokemon-species/%2A%2A"

    assert_response :not_found
  end
end
