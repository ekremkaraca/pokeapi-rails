require "test_helper"

class Api::V2::ItemAttributeControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeItemAttribute.delete_all

    %w[countable consumable usable-overworld usable-in-battle holdable].each do |name|
      PokeItemAttribute.create!(name: name)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/item-attribute", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/item-attribute/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/item-attribute/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/item-attribute", params: { q: "battle" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 1, payload["count"]
    assert_equal [ "usable-in-battle" ], payload["results"].map { |record| record["name"] }
  end

  test "show supports retrieval by id and name" do
    attribute = PokeItemAttribute.find_by!(name: "countable")

    get "/api/v2/item-attribute/#{attribute.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal attribute.id, payload["id"]
    assert_equal "countable", payload["name"]

    get "/api/v2/item-attribute/COUNTABLE"
    assert_response :success
  end

test "show query count stays within budget" do
  query_count = capture_select_query_count do
    get "/api/v2/item-attribute/countable"
    assert_response :success
  end

  assert_operator query_count, :<=, 14
end

  test "list and show accept trailing slash" do
    attribute = PokeItemAttribute.find_by!(name: "countable")

    get "/api/v2/item-attribute/"
    assert_response :success

    get "/api/v2/item-attribute/#{attribute.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v2/item-attribute", params: { limit: 2, offset: 0 }
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/item-attribute", params: { limit: 2, offset: 0 }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    attribute = PokeItemAttribute.find_by!(name: "countable")
    get "/api/v2/item-attribute/#{attribute.id}"
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/item-attribute/#{attribute.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/item-attribute/%2A%2A"

    assert_response :not_found
  end
end
