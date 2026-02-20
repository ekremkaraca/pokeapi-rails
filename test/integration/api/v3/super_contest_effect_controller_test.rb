require "test_helper"

class Api::V3::SuperContestEffectControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeSuperContestEffect.delete_all
    [ 2, 3, 4 ].each { |appeal| PokeSuperContestEffect.create!(appeal: appeal) }
  end

  test "list returns paginated summary data" do
    get "/api/v3/super-contest-effect", params: { limit: 2, offset: 0 }
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 3, payload["count"]
    assert_equal 2, payload["results"].size
    assert_equal %w[appeal id url], payload.fetch("results").first.keys.sort
  end

  test "list supports q over id text" do
    id = PokeSuperContestEffect.order(:id).first.id
    get "/api/v3/super-contest-effect", params: { q: id.to_s }
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 1, payload["count"]
  end

  test "show returns payload with standardized keys" do
    effect = PokeSuperContestEffect.order(:id).first
    get "/api/v3/super-contest-effect/#{effect.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[appeal id url], payload.keys.sort
  end
end
