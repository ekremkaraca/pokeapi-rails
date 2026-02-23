require "test_helper"
require "securerandom"

class Api::V2::PokemonEncountersControllerTest < ActionDispatch::IntegrationTest
  setup do
    Pokemon.delete_all
    @pokemon = Pokemon.create!(name: "encounter-mon")
  end

  test "show returns encounters payload with observability headers" do
    get "/api/v2/pokemon/#{@pokemon.id}/encounters"

    assert_response :success
    assert_observability_headers
    payload = JSON.parse(response.body)
    assert_kind_of Array, payload
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/pokemon/not-a-number/encounters"

    assert_response :not_found
    assert_observability_headers
  end

  test "show query count stays flat as encounter rows grow" do
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
      pokemon_id: @pokemon.id,
      version_id: version.id,
      location_area_id: location_area.id,
      encounter_slot_id: slot.id,
      min_level: 3,
      max_level: 4
    )
    PokeEncounterConditionValueMap.create!(encounter_id: encounter.id, encounter_condition_value_id: condition_value.id)

    first_count = capture_select_query_count do
      get "/api/v2/pokemon/#{@pokemon.id}/encounters"
      assert_response :success
      assert_observability_headers
    end

    2.times do |idx|
      row = PokeEncounter.create!(
        pokemon_id: @pokemon.id,
        version_id: version.id,
        location_area_id: location_area.id,
        encounter_slot_id: slot.id,
        min_level: 5 + idx,
        max_level: 8 + idx
      )
      PokeEncounterConditionValueMap.create!(encounter_id: row.id, encounter_condition_value_id: condition_value.id)
    end

    second_count = capture_select_query_count do
      get "/api/v2/pokemon/#{@pokemon.id}/encounters"
      assert_response :success
      assert_observability_headers
    end

    assert_equal first_count, second_count
  end
end
