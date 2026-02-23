require "test_helper"

class Api::V2::SuperContestEffectControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeSuperContestEffect.delete_all

    [
      { appeal: 2 },
      { appeal: 2 },
      { appeal: 3 },
      { appeal: 1 },
      { appeal: 0 }
    ].each do |attrs|
      PokeSuperContestEffect.create!(attrs)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/super-contest-effect", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal [ "url" ], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/super-contest-effect/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/super-contest-effect/\d+//$}, payload["results"].first["url"])
  end

  test "show supports retrieval by id" do
    super_contest_effect = PokeSuperContestEffect.first

    get "/api/v2/super-contest-effect/#{super_contest_effect.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal super_contest_effect.id, payload["id"]
    assert_equal super_contest_effect.appeal, payload["appeal"]
  end

  test "show query count stays within budget" do
    super_contest_effect = PokeSuperContestEffect.first

    query_count = capture_select_query_count do
      get "/api/v2/super-contest-effect/#{super_contest_effect.id}"
      assert_response :success
    end

    assert_operator query_count, :<=, 14
  end

  test "list and show accept trailing slash" do
    super_contest_effect = PokeSuperContestEffect.first

    get "/api/v2/super-contest-effect/"
    assert_response :success

    get "/api/v2/super-contest-effect/#{super_contest_effect.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/super-contest-effect/abc"

    assert_response :not_found
  end
end
