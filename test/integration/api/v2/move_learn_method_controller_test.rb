require "test_helper"

class Api::V2::MoveLearnMethodControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeMoveLearnMethod.delete_all

    [
      "level-up",
      "egg",
      "tutor",
      "machine"
    ].each do |name|
      PokeMoveLearnMethod.create!(name: name)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/move-learn-method", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 4, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/move-learn-method/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/move-learn-method/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/move-learn-method", params: { q: "up" }

    assert_response :success
    payload = JSON.parse(response.body)
    names = payload["results"].map { |record| record["name"] }

    assert_equal 1, payload["count"]
    assert_equal ["level-up"], names
  end

  test "show supports retrieval by id and name" do
    method = PokeMoveLearnMethod.find_by!(name: "level-up")

    get "/api/v2/move-learn-method/#{method.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal method.id, payload["id"]
    assert_equal "level-up", payload["name"]

    get "/api/v2/move-learn-method/LEVEL-UP"
    assert_response :success
  end

  test "list and show accept trailing slash" do
    method = PokeMoveLearnMethod.find_by!(name: "level-up")

    get "/api/v2/move-learn-method/"
    assert_response :success

    get "/api/v2/move-learn-method/#{method.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/move-learn-method/%2A%2A"

    assert_response :not_found
  end
end
