require "test_helper"

class Api::V3::TypeControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeType.delete_all
    PokePokemonType.delete_all
    Pokemon.delete_all

    [
      { name: "normal", generation_id: 1, damage_class_id: nil },
      { name: "fire", generation_id: 1, damage_class_id: 3 },
      { name: "water", generation_id: 1, damage_class_id: 3 },
      { name: "electric", generation_id: 1, damage_class_id: 3 },
      { name: "grass", generation_id: 1, damage_class_id: 3 }
    ].each do |attrs|
      PokeType.create!(attrs)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/type", params: { limit: 3, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 3, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[id name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/type/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/type", params: { q: "wat" }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "water", payload["results"].first["name"]
  end

  test "list supports filter by name" do
    get "/api/v3/type", params: { filter: { name: "fire" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "fire", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/type", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "water", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/type", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "list supports include pokemon" do
    type = PokeType.find_by!(name: "fire")
    pokemon = Pokemon.create!(name: "charmander")
    PokePokemonType.create!(pokemon_id: pokemon.id, type_id: type.id, slot: 1)

    get "/api/v3/type", params: { q: "fire", include: "pokemon" }
    assert_response :success
    payload = JSON.parse(response.body)

    result = payload.fetch("results").first
    assert_equal "fire", result["name"]
    assert_equal 1, result["pokemon"].length
    assert_equal 1, result.dig("pokemon", 0, "slot")
    assert_equal "charmander", result.dig("pokemon", 0, "pokemon", "name")
    assert_match(%r{/api/v3/pokemon/#{pokemon.id}/$}, result.dig("pokemon", 0, "pokemon", "url"))
    assert_query_count_at_most(6)
  end

  test "show returns type payload with standardized keys" do
    type = PokeType.find_by!(name: "fire")

    get "/api/v3/type/#{type.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[damage_class_id generation_id id name url], payload.keys.sort
    assert_equal type.id, payload["id"]
    assert_equal "fire", payload["name"]
    assert_equal 1, payload["generation_id"]
    assert_equal 3, payload["damage_class_id"]
    assert_match(%r{/api/v3/type/#{type.id}/$}, payload["url"])
  end

  test "show supports lookup by name and keeps canonical numeric url" do
    type = PokeType.create!(name: "steel", generation_id: 2, damage_class_id: 3)

    get "/api/v3/type/steel"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal type.id, payload["id"]
    assert_equal "steel", payload["name"]
    assert_match(%r{/api/v3/type/#{type.id}/$}, payload["url"])
  end

  test "show supports case-insensitive name lookup" do
    type = PokeType.create!(name: "steel", generation_id: 2, damage_class_id: 3)

    get "/api/v3/type/StEeL"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal type.id, payload["id"]
    assert_equal "steel", payload["name"]
  end

  test "show supports include pokemon" do
    type = PokeType.find_by!(name: "fire")
    pokemon = Pokemon.create!(name: "charmander")
    PokePokemonType.create!(pokemon_id: pokemon.id, type_id: type.id, slot: 1)

    get "/api/v3/type/#{type.id}", params: { include: "pokemon" }
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["pokemon"].length
    assert_equal 1, payload.dig("pokemon", 0, "slot")
    assert_equal "charmander", payload.dig("pokemon", 0, "pokemon", "name")
    assert_query_count_at_most(4)
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/type/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_not_found_error_envelope(payload)
  end

  test "show returns standardized not found envelope for unknown name" do
    get "/api/v3/type/not-a-real-type"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_not_found_error_envelope(payload)
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/type", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "fields", invalid_values: [ "unknown" ])
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/type", params: { include: "unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "include", invalid_values: [ "unknown" ])
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/type", params: { sort: "generation_id" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "sort", invalid_values: [ "generation_id" ])
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/type", params: { filter: { generation_id: "1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "filter", invalid_values: [ "generation_id" ])
  end

  test "list and show accept trailing slash" do
    type = PokeType.find_by!(name: "fire")

    get "/api/v3/type/"
    assert_response :success

    get "/api/v3/type/#{type.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/type", params: { limit: 3, offset: 0, q: "e" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/type", params: { limit: 3, offset: 0, q: "e" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    type = PokeType.find_by!(name: "fire")

    get "/api/v3/type/#{type.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/type/#{type.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "list etag varies by sort parameter" do
    get "/api/v3/type", params: { limit: 3, sort: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/type", params: { limit: 3, sort: "-name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "list etag varies by include parameter" do
    type = PokeType.find_by!(name: "fire")
    pokemon = Pokemon.create!(name: "charmander")
    PokePokemonType.create!(pokemon_id: pokemon.id, type_id: type.id, slot: 1)

    get "/api/v3/type", params: { q: "fire" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/type", params: { q: "fire", include: "pokemon" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    type = PokeType.find_by!(name: "fire")

    get "/api/v3/type/#{type.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/type/#{type.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
