require "test_helper"

class Api::V2::GrowthRateControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeGrowthRate.delete_all

    [
      { name: "slow", formula: "\\frac{5x^3}{4}" },
      { name: "medium", formula: "x^3" },
      { name: "fast", formula: "\\frac{4x^3}{5}" },
      { name: "medium-slow", formula: "\\frac{6x^3}{5}" },
      { name: "erratic", formula: "varies" }
    ].each do |attrs|
      PokeGrowthRate.create!(attrs)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/growth-rate", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/growth-rate/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/growth-rate/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/growth-rate", params: { q: "slow" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 2, payload["count"]
  end

  test "show supports retrieval by id and name" do
    growth_rate = PokeGrowthRate.find_by!(name: "slow")

    get "/api/v2/growth-rate/#{growth_rate.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal growth_rate.id, payload["id"]
    assert_equal "slow", payload["name"]
    assert_equal "\\frac{5x^3}{4}", payload["formula"]

    get "/api/v2/growth-rate/SLOW"
    assert_response :success
  end

  test "list and show accept trailing slash" do
    growth_rate = PokeGrowthRate.find_by!(name: "slow")

    get "/api/v2/growth-rate/"
    assert_response :success

    get "/api/v2/growth-rate/#{growth_rate.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/growth-rate/%2A%2A"

    assert_response :not_found
  end
end
