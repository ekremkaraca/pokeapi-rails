require "test_helper"

class Api::V3::EncounterConditionControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeEncounterCondition.delete_all

    %w[swarm time radar season weekday].each do |name|
      PokeEncounterCondition.create!(name: name)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/encounter-condition", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[id name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/encounter-condition/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/encounter-condition", params: { q: "rad" }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal [ "radar" ], payload.fetch("results").map { |record| record["name"] }
  end

  test "list supports filter by name" do
    get "/api/v3/encounter-condition", params: { filter: { name: "swarm" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "swarm", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/encounter-condition", params: { q: "rad", filter: { name: "radar" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "radar", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/encounter-condition", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "weekday", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/encounter-condition", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "show returns encounter condition payload with standardized keys" do
    condition = PokeEncounterCondition.find_by!(name: "swarm")

    get "/api/v3/encounter-condition/#{condition.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[id name url], payload.keys.sort
    assert_equal condition.id, payload["id"]
    assert_equal "swarm", payload["name"]
    assert_match(%r{/api/v3/encounter-condition/#{condition.id}/$}, payload["url"])
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/encounter-condition/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_not_found_error_envelope(payload)
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/encounter-condition", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "fields", invalid_values: [ "unknown" ])
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/encounter-condition", params: { include: "unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "include", invalid_values: [ "unknown" ])
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/encounter-condition", params: { sort: "created_at" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "sort", invalid_values: [ "created_at" ])
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/encounter-condition", params: { filter: { id: "1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "filter", invalid_values: [ "id" ])
  end

  test "list and show accept trailing slash" do
    condition = PokeEncounterCondition.find_by!(name: "swarm")

    get "/api/v3/encounter-condition/"
    assert_response :success

    get "/api/v3/encounter-condition/#{condition.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/encounter-condition", params: { limit: 2, offset: 0, q: "rad" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/encounter-condition", params: { limit: 2, offset: 0, q: "rad" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    condition = PokeEncounterCondition.find_by!(name: "swarm")

    get "/api/v3/encounter-condition/#{condition.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/encounter-condition/#{condition.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "list etag varies by sort parameter" do
    get "/api/v3/encounter-condition", params: { limit: 2, sort: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/encounter-condition", params: { limit: 2, sort: "-name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    condition = PokeEncounterCondition.find_by!(name: "swarm")

    get "/api/v3/encounter-condition/#{condition.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/encounter-condition/#{condition.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
