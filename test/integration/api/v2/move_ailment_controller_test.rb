require "test_helper"

class Api::V2::MoveAilmentControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeMoveAilment.delete_all

    [
      { id: -1, name: "unknown" },
      { id: 0, name: "none" },
      { id: 1, name: "paralysis" },
      { id: 2, name: "sleep" },
      { id: 3, name: "freeze" }
    ].each do |attrs|
      PokeMoveAilment.create!(attrs)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/move-ailment", params: { limit: 3, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 3, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/move-ailment/[-]?\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/move-ailment/[-]?\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/move-ailment", params: { q: "s" }

    assert_response :success
    payload = JSON.parse(response.body)
    names = payload["results"].map { |record| record["name"] }

    assert_equal 2, payload["count"]
    assert_includes names, "sleep"
    assert_includes names, "paralysis"
  end

  test "show supports retrieval by id and name" do
    get "/api/v2/move-ailment/-1"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal(-1, payload["id"])
    assert_equal "unknown", payload["name"]

    get "/api/v2/move-ailment/PARALYSIS"
    assert_response :success
  end

  test "list and show accept trailing slash" do
    get "/api/v2/move-ailment/"
    assert_response :success

    get "/api/v2/move-ailment/-1/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/move-ailment/%2A%2A"

    assert_response :not_found
  end
end
