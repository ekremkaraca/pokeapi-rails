require "test_helper"

class Api::V2::ItemCategoryControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeItemCategory.delete_all

    [
      { name: "stat-boosts", pocket_id: 7 },
      { name: "medicine", pocket_id: 2 },
      { name: "special-balls", pocket_id: 3 },
      { name: "all-machines", pocket_id: 4 },
      { name: "battle-items", pocket_id: 7 }
    ].each do |attrs|
      PokeItemCategory.create!(attrs)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/item-category", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/item-category/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/item-category/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/item-category", params: { q: "battle" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 1, payload["count"]
    assert_equal ["battle-items"], payload["results"].map { |record| record["name"] }
  end

  test "show supports retrieval by id and name" do
    category = PokeItemCategory.find_by!(name: "medicine")

    get "/api/v2/item-category/#{category.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal category.id, payload["id"]
    assert_equal "medicine", payload["name"]
    assert_equal 2, payload["pocket_id"]

    get "/api/v2/item-category/MEDICINE"
    assert_response :success
  end

  test "list and show accept trailing slash" do
    category = PokeItemCategory.find_by!(name: "medicine")

    get "/api/v2/item-category/"
    assert_response :success

    get "/api/v2/item-category/#{category.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/item-category/%2A%2A"

    assert_response :not_found
  end
end
