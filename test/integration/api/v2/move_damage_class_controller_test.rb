require "test_helper"

class Api::V2::MoveDamageClassControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeMoveDamageClass.delete_all

    %w[status physical special].each do |name|
      PokeMoveDamageClass.create!(name: name)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/move-damage-class", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 3, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/move-damage-class/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/move-damage-class/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/move-damage-class", params: { q: "spec" }

    assert_response :success
    payload = JSON.parse(response.body)
    names = payload["results"].map { |record| record["name"] }

    assert_equal 1, payload["count"]
    assert_equal [ "special" ], names
  end

  test "show supports retrieval by id and name" do
    mdc = PokeMoveDamageClass.find_by!(name: "status")

    get "/api/v2/move-damage-class/#{mdc.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal mdc.id, payload["id"]
    assert_equal "status", payload["name"]

    get "/api/v2/move-damage-class/STATUS"
    assert_response :success
  end

  test "list and show accept trailing slash" do
    mdc = PokeMoveDamageClass.find_by!(name: "status")

    get "/api/v2/move-damage-class/"
    assert_response :success

    get "/api/v2/move-damage-class/#{mdc.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/move-damage-class/%2A%2A"

    assert_response :not_found
  end
end
