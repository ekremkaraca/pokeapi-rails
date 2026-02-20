require "test_helper"

class Api::V3::CharacteristicControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeCharacteristic.delete_all

    [
      { gene_mod_5: -1, stat_id: 1 },
      { gene_mod_5: 0, stat_id: 2 },
      { gene_mod_5: 1, stat_id: 3 }
    ].each { |attrs| PokeCharacteristic.create!(attrs) }
  end

  test "list returns paginated summary data" do
    get "/api/v3/characteristic", params: { limit: 2, offset: 0 }
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 3, payload["count"]
    assert_equal 2, payload["results"].size
    assert_equal %w[gene_mod_5 id stat_id url], payload.fetch("results").first.keys.sort
  end

  test "list supports q over id text" do
    id = PokeCharacteristic.order(:id).first.id
    get "/api/v3/characteristic", params: { q: id.to_s }
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 1, payload["count"]
  end

  test "show returns payload with standardized keys" do
    characteristic = PokeCharacteristic.order(:id).first
    get "/api/v3/characteristic/#{characteristic.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[gene_mod_5 id stat_id url], payload.keys.sort
  end

  test "invalid filter returns invalid_query" do
    get "/api/v3/characteristic", params: { filter: { name: "x" } }
    assert_response :bad_request
    payload = JSON.parse(response.body)
    assert_equal "filter", payload.dig("error", "details", "param")
  end
end
