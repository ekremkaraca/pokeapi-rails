require "test_helper"
require "securerandom"

class Api::V2::PokemonControllerTest < ActionDispatch::IntegrationTest
  setup do
    Pokemon.delete_all

    %w[bulbasaur ivysaur venusaur charmeleon charizard].each do |name|
      Pokemon.create!(name: name)
    end

    25.times do |idx|
      Pokemon.create!(name: "pokemon-#{idx + 1}")
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/pokemon", params: { limit: 5, offset: 2 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 30, payload["count"]
    assert_equal 5, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/pokemon/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/pokemon/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/pokemon", params: { q: "SAUR" }

    assert_response :success
    payload = JSON.parse(response.body)
    names = payload["results"].map { |record| record["name"] }

    assert_equal 3, payload["count"]
    assert_includes names, "bulbasaur"
    assert_includes names, "ivysaur"
    assert_includes names, "venusaur"
  end

  test "show supports retrieval by id" do
    pokemon = Pokemon.find_by!(name: "bulbasaur")

    get "/api/v2/pokemon/#{pokemon.id}"

    assert_response :success
    assert_observability_headers
    payload = JSON.parse(response.body)
    assert_equal "bulbasaur", payload["name"]
    assert_equal pokemon.id, payload["id"]
    assert_equal %w[abilities base_experience cries forms game_indices height held_items id is_default location_area_encounters moves name order past_abilities past_stats past_types species sprites stats types weight], payload.keys.sort
  end

  test "show supports retrieval by name" do
    get "/api/v2/pokemon/BULBASAUR"

    assert_response :success
    assert_observability_headers
    payload = JSON.parse(response.body)
    assert_equal "bulbasaur", payload["name"]
    assert_nil payload["url"]
  end

  test "show query count stays within budget" do
    query_count = capture_select_query_count do
      get "/api/v2/pokemon/bulbasaur"
      assert_response :success
    end

    assert_operator query_count, :<=, 14
  end

  test "list supports conditional get with etag" do
    get "/api/v2/pokemon", params: { limit: 5, offset: 0, q: "saur" }
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/pokemon", params: { limit: 5, offset: 0, q: "saur" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    pokemon = Pokemon.find_by!(name: "bulbasaur")

    get "/api/v2/pokemon/#{pokemon.id}"
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/pokemon/#{pokemon.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "list and show accept trailing slash" do
    pokemon = Pokemon.find_by!(name: "bulbasaur")

    get "/api/v2/pokemon/"
    assert_response :success

    get "/api/v2/pokemon/#{pokemon.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/pokemon/%2A%2A"

    assert_response :not_found
    assert_equal({ "detail" => "Not found." }, JSON.parse(response.body))
  end

  test "encounters requires numeric id and existing pokemon" do
    pokemon = Pokemon.find_by!(name: "bulbasaur")

    get "/api/v2/pokemon/#{pokemon.id}/encounters"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_kind_of Array, payload
    if payload.first
      assert_equal %w[location_area version_details], payload.first.keys.sort
    end

    get "/api/v2/pokemon/not-a-number/encounters"
    assert_response :not_found
  end

  test "encounters query count stays flat as encounter rows grow" do
    pokemon = Pokemon.find_by!(name: "bulbasaur")
    suffix = SecureRandom.hex(6)
    version_group = PokeVersionGroup.create!(name: "vg-#{suffix}")
    version = PokeVersion.create!(name: "version-#{suffix}", version_group_id: version_group.id)
    location_area = PokeLocationArea.create!(name: "area-#{suffix}")
    method = PokeEncounterMethod.create!(name: "method-#{suffix}")
    slot = PokeEncounterSlot.create!(encounter_method_id: method.id, version_group_id: version_group.id, slot: 1, rarity: 30)
    condition = PokeEncounterCondition.create!(name: "condition-#{suffix}")
    condition_value = PokeEncounterConditionValue.create!(
      name: "condition-value-#{suffix}",
      encounter_condition_id: condition.id,
      is_default: true
    )

    encounter = PokeEncounter.create!(
      pokemon_id: pokemon.id,
      version_id: version.id,
      location_area_id: location_area.id,
      encounter_slot_id: slot.id,
      min_level: 3,
      max_level: 4
    )
    PokeEncounterConditionValueMap.create!(encounter_id: encounter.id, encounter_condition_value_id: condition_value.id)

    first_count = capture_select_query_count do
      get "/api/v2/pokemon/#{pokemon.id}/encounters"
      assert_response :success
    end

    2.times do |idx|
      row = PokeEncounter.create!(
        pokemon_id: pokemon.id,
        version_id: version.id,
        location_area_id: location_area.id,
        encounter_slot_id: slot.id,
        min_level: 5 + idx,
        max_level: 8 + idx
      )
      PokeEncounterConditionValueMap.create!(encounter_id: row.id, encounter_condition_value_id: condition_value.id)
    end

    second_count = capture_select_query_count do
      get "/api/v2/pokemon/#{pokemon.id}/encounters"
      assert_response :success
    end

    assert_equal first_count, second_count
  end
end
