require "test_helper"

class Api::V3::BerryFirmnessControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeBerry.delete_all
    PokeBerryFirmness.delete_all

    very_soft = PokeBerryFirmness.create!(name: "very-soft")
    soft = PokeBerryFirmness.create!(name: "soft")
    hard = PokeBerryFirmness.create!(name: "hard")

    [
      { name: "cheri", item_id: 126, berry_firmness_id: soft.id, natural_gift_power: 60, natural_gift_type_id: 10, size: 20, max_harvest: 5, growth_time: 3, soil_dryness: 15, smoothness: 25 },
      { name: "chesto", item_id: 127, berry_firmness_id: hard.id, natural_gift_power: 60, natural_gift_type_id: 11, size: 80, max_harvest: 5, growth_time: 3, soil_dryness: 15, smoothness: 25 },
      { name: "pecha", item_id: 128, berry_firmness_id: very_soft.id, natural_gift_power: 60, natural_gift_type_id: 13, size: 40, max_harvest: 5, growth_time: 3, soil_dryness: 15, smoothness: 25 }
    ].each do |attrs|
      PokeBerry.create!(attrs)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/berry-firmness", params: { limit: 2, offset: 0 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 3, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_nil payload["previous"]
    assert_equal %w[id name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/berry-firmness/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/berry-firmness", params: { q: "soft" }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 2, payload["count"]
  end

  test "list supports filter by name" do
    get "/api/v3/berry-firmness", params: { filter: { name: "hard" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "hard", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/berry-firmness", params: { q: "soft", filter: { name: "very-soft" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "very-soft", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/berry-firmness", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "very-soft", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/berry-firmness", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "list supports include berries" do
    get "/api/v3/berry-firmness", params: { filter: { name: "soft" }, include: "berries" }
    assert_response :success
    payload = JSON.parse(response.body)

    result = payload.fetch("results").first
    assert_equal "soft", result["name"]
    assert_equal [ "cheri" ], result.fetch("berries").map { |berry| berry.fetch("name") }
    assert_match(%r{/api/v3/berry/\d+/$}, result.dig("berries", 0, "url"))
  end

  test "show returns berry firmness payload with standardized keys" do
    firmness = PokeBerryFirmness.find_by!(name: "soft")

    get "/api/v3/berry-firmness/#{firmness.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[id name url], payload.keys.sort
    assert_equal firmness.id, payload["id"]
    assert_equal "soft", payload["name"]
    assert_match(%r{/api/v3/berry-firmness/#{firmness.id}/$}, payload["url"])
  end

  test "show supports include berries" do
    firmness = PokeBerryFirmness.find_by!(name: "hard")

    get "/api/v3/berry-firmness/#{firmness.id}", params: { include: "berries" }
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal [ "chesto" ], payload.fetch("berries").map { |berry| berry.fetch("name") }
    assert_match(%r{/api/v3/berry/\d+/$}, payload.dig("berries", 0, "url"))
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/berry-firmness/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_not_found_error_envelope(payload)
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/berry-firmness", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "fields", invalid_values: [ "unknown" ])
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/berry-firmness", params: { include: "unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "include", invalid_values: [ "unknown" ])
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/berry-firmness", params: { sort: "created_at" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "sort", invalid_values: [ "created_at" ])
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/berry-firmness", params: { filter: { id: "1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "filter", invalid_values: [ "id" ])
  end

  test "list and show accept trailing slash" do
    firmness = PokeBerryFirmness.find_by!(name: "soft")

    get "/api/v3/berry-firmness/"
    assert_response :success

    get "/api/v3/berry-firmness/#{firmness.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/berry-firmness", params: { limit: 2, offset: 0, q: "soft" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/berry-firmness", params: { limit: 2, offset: 0, q: "soft" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    firmness = PokeBerryFirmness.find_by!(name: "soft")

    get "/api/v3/berry-firmness/#{firmness.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/berry-firmness/#{firmness.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "list etag varies by include parameter" do
    get "/api/v3/berry-firmness", params: { q: "soft" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/berry-firmness", params: { q: "soft", include: "berries" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    firmness = PokeBerryFirmness.find_by!(name: "soft")

    get "/api/v3/berry-firmness/#{firmness.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/berry-firmness/#{firmness.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
