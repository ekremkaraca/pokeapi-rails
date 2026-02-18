require "test_helper"

class Api::V2::CharacteristicControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeCharacteristic.delete_all

    [
      { stat_id: 1, gene_mod_5: 0 },
      { stat_id: 1, gene_mod_5: 1 },
      { stat_id: 2, gene_mod_5: 2 },
      { stat_id: 3, gene_mod_5: 3 },
      { stat_id: 6, gene_mod_5: 4 }
    ].each do |attrs|
      PokeCharacteristic.create!(attrs)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/characteristic", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal ["url"], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/characteristic/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/characteristic/\d+//$}, payload["results"].first["url"])
  end

  test "show supports retrieval by id" do
    characteristic = PokeCharacteristic.first

    get "/api/v2/characteristic/#{characteristic.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal characteristic.id, payload["id"]
    assert_equal characteristic.stat_id, payload["stat_id"]
    assert_equal characteristic.gene_mod_5, payload["gene_mod_5"]
  end

  test "list and show accept trailing slash" do
    characteristic = PokeCharacteristic.first

    get "/api/v2/characteristic/"
    assert_response :success

    get "/api/v2/characteristic/#{characteristic.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/characteristic/abc"

    assert_response :not_found
  end
end
