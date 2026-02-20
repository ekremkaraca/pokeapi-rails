require "test_helper"

class Api::V3::StatControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeStat.delete_all

    [
      { name: "hp", game_index: 1, is_battle_only: false, damage_class_id: nil },
      { name: "attack", game_index: 2, is_battle_only: false, damage_class_id: 2 },
      { name: "defense", game_index: 3, is_battle_only: false, damage_class_id: 2 }
    ].each { |attrs| PokeStat.create!(attrs) }
  end

  test "list returns paginated summary data" do
    get "/api/v3/stat", params: { limit: 2, offset: 0 }
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 3, payload["count"]
    assert_equal 2, payload["results"].size
    assert_equal %w[damage_class_id game_index id is_battle_only name url], payload.fetch("results").first.keys.sort
  end

  test "list supports q and filter by name" do
    get "/api/v3/stat", params: { q: "att", filter: { name: "attack" } }
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 1, payload["count"]
    assert_equal "attack", payload.dig("results", 0, "name")
  end

  test "show returns payload with standardized keys" do
    stat = PokeStat.find_by!(name: "attack")
    get "/api/v3/stat/#{stat.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[damage_class_id game_index id is_battle_only name url], payload.keys.sort
  end
end
