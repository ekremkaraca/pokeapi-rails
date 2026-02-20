require "test_helper"

class Api::V2::BerryFlavorControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeBerryFlavor.delete_all

    [
      { name: "spicy", contest_type_id: 1 },
      { name: "dry", contest_type_id: 2 },
      { name: "sweet", contest_type_id: 3 },
      { name: "bitter", contest_type_id: 4 },
      { name: "sour", contest_type_id: 5 }
    ].each do |attrs|
      PokeBerryFlavor.create!(attrs)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/berry-flavor", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/berry-flavor/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/berry-flavor/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/berry-flavor", params: { q: "bit" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 1, payload["count"]
    assert_equal [ "bitter" ], payload["results"].map { |record| record["name"] }
  end

  test "show supports retrieval by id and name" do
    flavor = PokeBerryFlavor.find_by!(name: "spicy")

    get "/api/v2/berry-flavor/#{flavor.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal flavor.id, payload["id"]
    assert_equal "spicy", payload["name"]
    assert_equal 1, payload["contest_type_id"]

    get "/api/v2/berry-flavor/SPICY"
    assert_response :success
  end

  test "list and show accept trailing slash" do
    flavor = PokeBerryFlavor.find_by!(name: "spicy")

    get "/api/v2/berry-flavor/"
    assert_response :success

    get "/api/v2/berry-flavor/#{flavor.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/berry-flavor/%2A%2A"

    assert_response :not_found
  end
end
