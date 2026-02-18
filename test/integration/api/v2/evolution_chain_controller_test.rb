require "test_helper"

class Api::V2::EvolutionChainControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeEvolutionChain.delete_all

    [
      { baby_trigger_item_id: nil },
      { baby_trigger_item_id: nil },
      { baby_trigger_item_id: 231 },
      { baby_trigger_item_id: nil }
    ].each do |attrs|
      PokeEvolutionChain.create!(attrs)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/evolution-chain", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 4, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal ["url"], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/evolution-chain/\d+/$}, payload["results"].first["url"])
  end

  test "show supports retrieval by id" do
    chain = PokeEvolutionChain.find_by!(baby_trigger_item_id: 231)

    get "/api/v2/evolution-chain/#{chain.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal chain.id, payload["id"]
    assert_equal 231, payload["baby_trigger_item_id"]
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/evolution-chain/abc"

    assert_response :not_found
  end
end
