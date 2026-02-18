require "test_helper"

class Api::V2::BerryFirmnessControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeBerryFirmness.delete_all

    %w[very-soft soft hard very-hard super-hard].each do |name|
      PokeBerryFirmness.create!(name: name)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/berry-firmness", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/berry-firmness/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/berry-firmness/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/berry-firmness", params: { q: "super" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 1, payload["count"]
    assert_equal ["super-hard"], payload["results"].map { |record| record["name"] }
  end

  test "show supports retrieval by id and name" do
    firmness = PokeBerryFirmness.find_by!(name: "soft")

    get "/api/v2/berry-firmness/#{firmness.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal firmness.id, payload["id"]
    assert_equal "soft", payload["name"]

    get "/api/v2/berry-firmness/SOFT"
    assert_response :success
  end

  test "list and show accept trailing slash" do
    firmness = PokeBerryFirmness.find_by!(name: "soft")

    get "/api/v2/berry-firmness/"
    assert_response :success

    get "/api/v2/berry-firmness/#{firmness.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/berry-firmness/%2A%2A"

    assert_response :not_found
  end
end
