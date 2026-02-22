require "test_helper"

class Api::V3::AbilityControllerTest < ActionDispatch::IntegrationTest
  setup do
    Ability.delete_all
    PokePokemonAbility.delete_all
    Pokemon.delete_all

    [
      { name: "stench", is_main_series: true },
      { name: "drizzle", is_main_series: true },
      { name: "swift-swim", is_main_series: true },
      { name: "chlorophyll", is_main_series: true },
      { name: "cloud-nine", is_main_series: true }
    ].each do |attrs|
      Ability.create!(attrs)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/ability", params: { limit: 3, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 3, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[id name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/ability/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/ability", params: { q: "swim" }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "swift-swim", payload["results"].first["name"]
  end

  test "list supports filter by name" do
    get "/api/v3/ability", params: { filter: { name: "stench" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "stench", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/ability", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "swift-swim", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/ability", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "list supports include pokemon" do
    ability = Ability.find_by!(name: "stench")
    pokemon = Pokemon.create!(name: "bulbasaur")
    PokePokemonAbility.create!(pokemon_id: pokemon.id, ability_id: ability.id, is_hidden: false, slot: 1)

    get "/api/v3/ability", params: { q: "stench", include: "pokemon" }
    assert_response :success
    payload = JSON.parse(response.body)

    result = payload.fetch("results").first
    assert_equal "stench", result["name"]
    assert_equal 1, result["pokemon"].length
    assert_equal "bulbasaur", result.dig("pokemon", 0, "pokemon", "name")
    assert_match(%r{/api/v3/pokemon/#{pokemon.id}/$}, result.dig("pokemon", 0, "pokemon", "url"))
    assert_query_count_at_most(6)
  end

  test "show returns ability payload with standardized keys" do
    ability = Ability.find_by!(name: "stench")

    get "/api/v3/ability/#{ability.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[id is_main_series name url], payload.keys.sort
    assert_equal ability.id, payload["id"]
    assert_equal "stench", payload["name"]
    assert_equal true, payload["is_main_series"]
    assert_match(%r{/api/v3/ability/#{ability.id}/$}, payload["url"])
  end

  test "show supports include pokemon" do
    ability = Ability.find_by!(name: "stench")
    pokemon = Pokemon.create!(name: "bulbasaur")
    PokePokemonAbility.create!(pokemon_id: pokemon.id, ability_id: ability.id, is_hidden: false, slot: 1)

    get "/api/v3/ability/#{ability.id}", params: { include: "pokemon" }
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["pokemon"].length
    assert_equal false, payload.dig("pokemon", 0, "is_hidden")
    assert_equal 1, payload.dig("pokemon", 0, "slot")
    assert_equal "bulbasaur", payload.dig("pokemon", 0, "pokemon", "name")
    assert_query_count_at_most(4)
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/ability/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_not_found_error_envelope(payload)
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/ability", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "fields", invalid_values: [ "unknown" ])
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/ability", params: { include: "unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "include", invalid_values: [ "unknown" ])
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/ability", params: { sort: "slot" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "sort", invalid_values: [ "slot" ])
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/ability", params: { filter: { slot: "1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "filter", invalid_values: [ "slot" ])
  end

  test "list and show accept trailing slash" do
    ability = Ability.find_by!(name: "stench")

    get "/api/v3/ability/"
    assert_response :success

    get "/api/v3/ability/#{ability.id}/"
    assert_response :success
  end

  test "responds with json even when html format is requested" do
    get "/api/v3/ability.html"

    assert_response :success
    assert_equal "application/json; charset=utf-8", response.headers["Content-Type"]
  end

  test "list supports conditional get with etag" do
    get "/api/v3/ability", params: { limit: 3, offset: 0, q: "s" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/ability", params: { limit: 3, offset: 0, q: "s" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    ability = Ability.find_by!(name: "stench")

    get "/api/v3/ability/#{ability.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/ability/#{ability.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "list etag varies by sort parameter" do
    get "/api/v3/ability", params: { limit: 3, sort: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/ability", params: { limit: 3, sort: "-name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "list etag varies by include parameter" do
    ability = Ability.find_by!(name: "stench")
    pokemon = Pokemon.create!(name: "bulbasaur")
    PokePokemonAbility.create!(pokemon_id: pokemon.id, ability_id: ability.id, is_hidden: false, slot: 1)

    get "/api/v3/ability", params: { q: "stench" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/ability", params: { q: "stench", include: "pokemon" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    ability = Ability.find_by!(name: "stench")

    get "/api/v3/ability/#{ability.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/ability/#{ability.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
