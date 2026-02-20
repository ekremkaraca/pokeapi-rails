require "test_helper"

class Api::V2::RegionControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeRegion.delete_all

    %w[kanto johto hoenn sinnoh unova].each do |name|
      PokeRegion.create!(name: name)
    end

    25.times do |idx|
      PokeRegion.create!(name: "region-#{idx + 1}")
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/region", params: { limit: 5, offset: 2 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 30, payload["count"]
    assert_equal 5, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/region/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/region/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/region", params: { q: "hto" }

    assert_response :success
    payload = JSON.parse(response.body)
    names = payload["results"].map { |record| record["name"] }

    assert_equal 1, payload["count"]
    assert_equal [ "johto" ], names
  end

  test "show supports retrieval by id and name" do
    region = PokeRegion.find_by!(name: "kanto")

    get "/api/v2/region/#{region.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal region.id, payload["id"]
    assert_equal "kanto", payload["name"]

    get "/api/v2/region/KANTO"
    assert_response :success
  end

  test "list and show accept trailing slash" do
    region = PokeRegion.find_by!(name: "kanto")

    get "/api/v2/region/"
    assert_response :success

    get "/api/v2/region/#{region.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/region/%2A%2A"

    assert_response :not_found
  end
end
