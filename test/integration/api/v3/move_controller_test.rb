require "test_helper"

class Api::V3::MoveControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeMove.delete_all
    PokePokemonMove.delete_all
    Pokemon.delete_all

    [
      { name: "tackle", power: 40, pp: 35, priority: 0, accuracy: 100, damage_class_id: 2, type_id: 1, target_id: 10 },
      { name: "quick-attack", power: 40, pp: 30, priority: 1, accuracy: 100, damage_class_id: 2, type_id: 1, target_id: 10 },
      { name: "thunderbolt", power: 90, pp: 15, priority: 0, accuracy: 100, damage_class_id: 3, type_id: 13, target_id: 10 },
      { name: "thunder", power: 110, pp: 10, priority: 0, accuracy: 70, damage_class_id: 3, type_id: 13, target_id: 10 },
      { name: "vine-whip", power: 45, pp: 25, priority: 0, accuracy: 100, damage_class_id: 2, type_id: 12, target_id: 10 }
    ].each do |attrs|
      PokeMove.create!(attrs)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/move", params: { limit: 3, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 3, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[id name power url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/move/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/move", params: { q: "thunder" }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 2, payload["count"]
    assert_equal %w[thunder thunderbolt], payload["results"].map { |record| record["name"] }.sort
  end

  test "list supports filter by name" do
    get "/api/v3/move", params: { filter: { name: "quick-attack" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "quick-attack", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/move", params: { q: "thunder", filter: { name: "thunderbolt" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "thunderbolt", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/move", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "vine-whip", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/move", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "list supports include pokemon" do
    move = PokeMove.find_by!(name: "tackle")
    pokemon = Pokemon.create!(name: "bulbasaur")
    PokePokemonMove.create!(pokemon_id: pokemon.id, move_id: move.id, pokemon_move_method_id: 1, version_group_id: 1, level: 1)

    get "/api/v3/move", params: { q: "tackle", include: "pokemon" }
    assert_response :success
    payload = JSON.parse(response.body)

    result = payload.fetch("results").first
    assert_equal "tackle", result["name"]
    assert_equal 1, result["pokemon"].length
    assert_equal "bulbasaur", result.dig("pokemon", 0, "pokemon", "name")
    assert_match(%r{/api/v3/pokemon/#{pokemon.id}/$}, result.dig("pokemon", 0, "pokemon", "url"))
    assert_query_count_at_most(6)
  end

  test "show returns move payload with standardized keys" do
    move = PokeMove.find_by!(name: "thunderbolt")

    get "/api/v3/move/#{move.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[accuracy damage_class_id id name power pp priority target_id type_id url], payload.keys.sort
    assert_equal move.id, payload["id"]
    assert_equal "thunderbolt", payload["name"]
    assert_equal 90, payload["power"]
    assert_match(%r{/api/v3/move/#{move.id}/$}, payload["url"])
  end

  test "show supports include pokemon" do
    move = PokeMove.find_by!(name: "tackle")
    pokemon = Pokemon.create!(name: "bulbasaur")
    PokePokemonMove.create!(pokemon_id: pokemon.id, move_id: move.id, pokemon_move_method_id: 1, version_group_id: 1, level: 1)

    get "/api/v3/move/#{move.id}", params: { include: "pokemon" }
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["pokemon"].length
    assert_equal "bulbasaur", payload.dig("pokemon", 0, "pokemon", "name")
    assert_query_count_at_most(4)
  end

  test "include pokemon is capped for high-cardinality move expansions" do
    move = PokeMove.find_by!(name: "tackle")

    30.times do |index|
      pokemon = Pokemon.create!(name: "species-#{index + 1}")
      PokePokemonMove.create!(pokemon_id: pokemon.id, move_id: move.id, pokemon_move_method_id: 1, version_group_id: 1, level: 1)
    end

    get "/api/v3/move/#{move.id}", params: { include: "pokemon" }
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 25, payload.fetch("pokemon").length
    assert_equal "species-1", payload.dig("pokemon", 0, "pokemon", "name")
    assert_equal "species-25", payload.dig("pokemon", 24, "pokemon", "name")
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/move/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_not_found_error_envelope(payload)
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/move", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "fields", invalid_values: [ "unknown" ])
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/move", params: { include: "unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "include", invalid_values: [ "unknown" ])
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/move", params: { sort: "power" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "sort", invalid_values: [ "power" ])
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/move", params: { filter: { power: "40" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "filter", invalid_values: [ "power" ])
  end

  test "list and show accept trailing slash" do
    move = PokeMove.find_by!(name: "tackle")

    get "/api/v3/move/"
    assert_response :success

    get "/api/v3/move/#{move.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/move", params: { limit: 3, offset: 0, q: "thunder" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/move", params: { limit: 3, offset: 0, q: "thunder" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    move = PokeMove.find_by!(name: "tackle")

    get "/api/v3/move/#{move.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/move/#{move.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "list etag varies by sort parameter" do
    get "/api/v3/move", params: { limit: 3, sort: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/move", params: { limit: 3, sort: "-name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "list etag varies by include parameter" do
    move = PokeMove.find_by!(name: "tackle")
    pokemon = Pokemon.create!(name: "bulbasaur")
    PokePokemonMove.create!(pokemon_id: pokemon.id, move_id: move.id, pokemon_move_method_id: 1, version_group_id: 1, level: 1)

    get "/api/v3/move", params: { q: "tackle" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/move", params: { q: "tackle", include: "pokemon" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    move = PokeMove.find_by!(name: "tackle")

    get "/api/v3/move/#{move.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/move/#{move.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
