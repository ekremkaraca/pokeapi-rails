require "test_helper"

class Api::V2::EncounterConditionControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeEncounterCondition.delete_all

    %w[swarm time radar season weekday].each do |name|
      PokeEncounterCondition.create!(name: name)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/encounter-condition", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/encounter-condition/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/encounter-condition/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/encounter-condition", params: { q: "rad" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 1, payload["count"]
    assert_equal ["radar"], payload["results"].map { |record| record["name"] }
  end

  test "show supports retrieval by id and name" do
    condition = PokeEncounterCondition.find_by!(name: "swarm")

    get "/api/v2/encounter-condition/#{condition.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal condition.id, payload["id"]
    assert_equal "swarm", payload["name"]

    get "/api/v2/encounter-condition/SWARM"
    assert_response :success
  end

  test "list and show accept trailing slash" do
    condition = PokeEncounterCondition.find_by!(name: "swarm")

    get "/api/v2/encounter-condition/"
    assert_response :success

    get "/api/v2/encounter-condition/#{condition.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/encounter-condition/%2A%2A"

    assert_response :not_found
  end
end
