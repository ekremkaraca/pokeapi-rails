require "test_helper"

class Api::V3::PalParkAreaControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokePalParkArea.delete_all
    %w[field forest mountain].each { |name| PokePalParkArea.create!(name: name) }
  end

  test "list returns paginated summary data" do
    get "/api/v3/pal-park-area", params: { limit: 2, offset: 0 }
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 3, payload["count"]
    assert_equal 2, payload["results"].size
    assert_equal %w[id name url], payload.fetch("results").first.keys.sort
  end

  test "list supports q and filter by name" do
    get "/api/v3/pal-park-area", params: { q: "for", filter: { name: "forest" } }
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 1, payload["count"]
    assert_equal "forest", payload.dig("results", 0, "name")
  end
end
