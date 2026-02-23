require "test_helper"

class Api::V2::ContestEffectControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeContestEffect.delete_all

    [
      { appeal: 4, jam: 0 },
      { appeal: 3, jam: 0 },
      { appeal: 6, jam: 0 },
      { appeal: 1, jam: 4 },
      { appeal: 1, jam: 3 }
    ].each do |attrs|
      PokeContestEffect.create!(attrs)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/contest-effect", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal [ "url" ], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/contest-effect/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/contest-effect/\d+//$}, payload["results"].first["url"])
  end

  test "show supports retrieval by id" do
    contest_effect = PokeContestEffect.first

    get "/api/v2/contest-effect/#{contest_effect.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal contest_effect.id, payload["id"]
    assert_equal contest_effect.appeal, payload["appeal"]
    assert_equal contest_effect.jam, payload["jam"]
  end

  test "show query count stays within budget" do
    contest_effect = PokeContestEffect.first

    query_count = capture_select_query_count do
      get "/api/v2/contest-effect/#{contest_effect.id}"
      assert_response :success
    end

    assert_operator query_count, :<=, 14
  end

  test "list and show accept trailing slash" do
    contest_effect = PokeContestEffect.first

    get "/api/v2/contest-effect/"
    assert_response :success

    get "/api/v2/contest-effect/#{contest_effect.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/contest-effect/abc"

    assert_response :not_found
  end
end
