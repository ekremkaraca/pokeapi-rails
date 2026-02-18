require "test_helper"

class Api::V2::ItemPocketControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeItemPocket.delete_all

    %w[misc medicine pokeballs machines battle].each do |name|
      PokeItemPocket.create!(name: name)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/item-pocket", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/item-pocket/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/item-pocket/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/item-pocket", params: { q: "med" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 1, payload["count"]
    assert_equal ["medicine"], payload["results"].map { |record| record["name"] }
  end

  test "show supports retrieval by id and name" do
    pocket = PokeItemPocket.find_by!(name: "misc")

    get "/api/v2/item-pocket/#{pocket.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal pocket.id, payload["id"]
    assert_equal "misc", payload["name"]

    get "/api/v2/item-pocket/MISC"
    assert_response :success
  end

  test "list and show accept trailing slash" do
    pocket = PokeItemPocket.find_by!(name: "misc")

    get "/api/v2/item-pocket/"
    assert_response :success

    get "/api/v2/item-pocket/#{pocket.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/item-pocket/%2A%2A"

    assert_response :not_found
  end
end
