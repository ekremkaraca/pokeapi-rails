require "test_helper"

class Api::V2::MoveCategoryControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeMoveMetaCategory.delete_all

    [
      "damage",
      "ailment",
      "net-good-stats",
      "heal",
      "damage+ailment",
      "field-effect"
    ].each do |name|
      PokeMoveMetaCategory.create!(name: name)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/move-category", params: { limit: 3, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 6, payload["count"]
    assert_equal 3, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/move-category/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/move-category/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/move-category", params: { q: "effect" }

    assert_response :success
    payload = JSON.parse(response.body)
    names = payload["results"].map { |record| record["name"] }

    assert_equal 1, payload["count"]
    assert_equal ["field-effect"], names
  end

  test "show supports retrieval by id and name" do
    category = PokeMoveMetaCategory.find_by!(name: "damage")

    get "/api/v2/move-category/#{category.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal category.id, payload["id"]
    assert_equal "damage", payload["name"]

    get "/api/v2/move-category/DAMAGE"
    assert_response :success
  end

  test "list and show accept trailing slash" do
    category = PokeMoveMetaCategory.find_by!(name: "damage")

    get "/api/v2/move-category/"
    assert_response :success

    get "/api/v2/move-category/#{category.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/move-category/%2A%2A"

    assert_response :not_found
  end
end
