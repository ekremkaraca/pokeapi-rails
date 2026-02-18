require "test_helper"

class Api::V2::MoveTargetControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeMoveTarget.delete_all

    [
      "specific-move",
      "selected-pokemon-me-first",
      "ally",
      "users-field",
      "user-or-ally",
      "opponents-field"
    ].each do |name|
      PokeMoveTarget.create!(name: name)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/move-target", params: { limit: 3, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 6, payload["count"]
    assert_equal 3, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/move-target/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/move-target/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/move-target", params: { q: "ally" }

    assert_response :success
    payload = JSON.parse(response.body)
    names = payload["results"].map { |record| record["name"] }

    assert_equal 2, payload["count"]
    assert_includes names, "ally"
    assert_includes names, "user-or-ally"
  end

  test "show supports retrieval by id and name" do
    target = PokeMoveTarget.find_by!(name: "specific-move")

    get "/api/v2/move-target/#{target.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal target.id, payload["id"]
    assert_equal "specific-move", payload["name"]

    get "/api/v2/move-target/SPECIFIC-MOVE"
    assert_response :success
  end

  test "list and show accept trailing slash" do
    target = PokeMoveTarget.find_by!(name: "specific-move")

    get "/api/v2/move-target/"
    assert_response :success

    get "/api/v2/move-target/#{target.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/move-target/%2A%2A"

    assert_response :not_found
  end
end
