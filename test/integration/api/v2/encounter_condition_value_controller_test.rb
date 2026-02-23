require "test_helper"

class Api::V2::EncounterConditionValueControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeEncounterConditionValue.delete_all

    [
      { name: "swarm-yes", encounter_condition_id: 1, is_default: false },
      { name: "swarm-no", encounter_condition_id: 1, is_default: true },
      { name: "time-morning", encounter_condition_id: 2, is_default: false },
      { name: "time-day", encounter_condition_id: 2, is_default: true },
      { name: "time-night", encounter_condition_id: 2, is_default: false }
    ].each do |attrs|
      PokeEncounterConditionValue.create!(attrs)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/encounter-condition-value", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/encounter-condition-value/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/encounter-condition-value/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/encounter-condition-value", params: { q: "time-" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 3, payload["count"]
  end

  test "show supports retrieval by id and name" do
    value = PokeEncounterConditionValue.find_by!(name: "swarm-no")

    get "/api/v2/encounter-condition-value/#{value.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal value.id, payload["id"]
    assert_equal "swarm-no", payload["name"]
    assert_equal 1, payload["encounter_condition_id"]
    assert_equal true, payload["is_default"]

    get "/api/v2/encounter-condition-value/SWARM-NO"
    assert_response :success
  end

test "show query count stays within budget" do
  query_count = capture_select_query_count do
    get "/api/v2/encounter-condition-value/swarm-no"
    assert_response :success
  end

  assert_operator query_count, :<=, 14
end

  test "list and show accept trailing slash" do
    value = PokeEncounterConditionValue.find_by!(name: "swarm-no")

    get "/api/v2/encounter-condition-value/"
    assert_response :success

    get "/api/v2/encounter-condition-value/#{value.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v2/encounter-condition-value", params: { limit: 2, offset: 0 }
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/encounter-condition-value", params: { limit: 2, offset: 0 }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    value = PokeEncounterConditionValue.find_by!(name: "swarm-no")
    get "/api/v2/encounter-condition-value/#{value.id}"
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/encounter-condition-value/#{value.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/encounter-condition-value/%2A%2A"

    assert_response :not_found
  end
end
