require "test_helper"

class Api::V3::PokeathlonStatControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokePokeathlonStat.delete_all
    %w[speed jump power].each { |name| PokePokeathlonStat.create!(name: name) }
  end

  test "list returns paginated summary data" do
    get "/api/v3/pokeathlon-stat", params: { limit: 2, offset: 0 }
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 3, payload["count"]
    assert_equal 2, payload["results"].size
    assert_equal %w[id name url], payload.fetch("results").first.keys.sort
  end

  test "show returns standardized payload" do
    stat = PokePokeathlonStat.find_by!(name: "speed")
    get "/api/v3/pokeathlon-stat/#{stat.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[id name url], payload.keys.sort
  end
end
