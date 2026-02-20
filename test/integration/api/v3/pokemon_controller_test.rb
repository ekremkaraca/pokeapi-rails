require "test_helper"

class Api::V3::PokemonControllerTest < ActionDispatch::IntegrationTest
  setup do
    Pokemon.delete_all
    PokePokemonAbility.delete_all
    Ability.delete_all

    %w[bulbasaur ivysaur venusaur charmeleon charizard].each do |name|
      Pokemon.create!(name: name)
    end

    10.times do |idx|
      Pokemon.create!(name: "pokemon-#{idx + 1}")
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/pokemon", params: { limit: 5, offset: 2 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 15, payload["count"]
    assert_equal 5, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[id name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/pokemon/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/pokemon", params: { q: "saur" }

    assert_response :success
    payload = JSON.parse(response.body)
    names = payload["results"].map { |record| record["name"] }

    assert_equal 3, payload["count"]
    assert_includes names, "bulbasaur"
    assert_includes names, "ivysaur"
    assert_includes names, "venusaur"
  end

  test "list supports filter by name" do
    get "/api/v3/pokemon", params: { filter: { name: "bulbasaur" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "bulbasaur", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/pokemon", params: { q: "saur", filter: { name: "bulbasaur" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "bulbasaur", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/pokemon", params: { q: "saur", sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "venusaur", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/pokemon", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "list supports include abilities" do
    pokemon = Pokemon.find_by!(name: "bulbasaur")
    ability = Ability.create!(name: "overgrow", is_main_series: true)
    PokePokemonAbility.create!(pokemon_id: pokemon.id, ability_id: ability.id, is_hidden: false, slot: 1)

    get "/api/v3/pokemon", params: { q: "bulba", include: "abilities" }
    assert_response :success
    payload = JSON.parse(response.body)

    result = payload.fetch("results").first
    assert_equal "bulbasaur", result["name"]
    assert_equal 1, result["abilities"].length
    assert_equal "overgrow", result.dig("abilities", 0, "ability", "name")
    assert_match(%r{/api/v3/ability/#{ability.id}/$}, result.dig("abilities", 0, "ability", "url"))
  end

  test "show returns id name and canonical url" do
    pokemon = Pokemon.find_by!(name: "bulbasaur")

    get "/api/v3/pokemon/#{pokemon.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal pokemon.id, payload["id"]
    assert_equal "bulbasaur", payload["name"]
    assert_match(%r{/api/v3/pokemon/#{pokemon.id}/$}, payload["url"])
  end

  test "show supports fields filter" do
    pokemon = Pokemon.find_by!(name: "bulbasaur")

    get "/api/v3/pokemon/#{pokemon.id}", params: { fields: "name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal({ "name" => "bulbasaur" }, payload)
  end

  test "show supports include abilities" do
    pokemon = Pokemon.find_by!(name: "bulbasaur")
    ability = Ability.create!(name: "overgrow", is_main_series: true)
    PokePokemonAbility.create!(pokemon_id: pokemon.id, ability_id: ability.id, is_hidden: false, slot: 1)

    get "/api/v3/pokemon/#{pokemon.id}", params: { include: "abilities" }
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["abilities"].length
    assert_equal false, payload.dig("abilities", 0, "is_hidden")
    assert_equal 1, payload.dig("abilities", 0, "slot")
    assert_equal "overgrow", payload.dig("abilities", 0, "ability", "name")
  end

  test "show returns standardized not found error envelope" do
    get "/api/v3/pokemon/999999"

    assert_response :not_found
    assert_equal "experimental", response.headers["X-API-Stability"]
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    payload = JSON.parse(response.body)

    assert_equal %w[error], payload.keys
    assert_equal "not_found", payload.dig("error", "code")
    assert_equal "Resource not found", payload.dig("error", "message")
    assert_kind_of Hash, payload.dig("error", "details")
    assert_kind_of String, payload.dig("error", "request_id")
    assert payload.dig("error", "request_id").present?
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/pokemon", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "Invalid query parameter", payload.dig("error", "message")
    assert_equal "fields", payload.dig("error", "details", "param")
    assert_equal ["unknown"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/pokemon", params: { include: "unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "include", payload.dig("error", "details", "param")
    assert_equal ["unknown"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/pokemon", params: { sort: "-weight" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "sort", payload.dig("error", "details", "param")
    assert_equal ["weight"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/pokemon", params: { filter: { weight: "10" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "filter", payload.dig("error", "details", "param")
    assert_equal ["weight"], payload.dig("error", "details", "invalid_values")
  end

  test "list and show accept trailing slash" do
    pokemon = Pokemon.find_by!(name: "bulbasaur")

    get "/api/v3/pokemon/"
    assert_response :success

    get "/api/v3/pokemon/#{pokemon.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/pokemon", params: { limit: 5, offset: 0, q: "saur" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/pokemon", params: { limit: 5, offset: 0, q: "saur" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    pokemon = Pokemon.find_by!(name: "bulbasaur")

    get "/api/v3/pokemon/#{pokemon.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/pokemon/#{pokemon.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "list etag varies by sort parameter" do
    get "/api/v3/pokemon", params: { limit: 5, sort: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/pokemon", params: { limit: 5, sort: "-name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "list etag varies by include parameter" do
    pokemon = Pokemon.find_by!(name: "bulbasaur")
    ability = Ability.create!(name: "overgrow", is_main_series: true)
    PokePokemonAbility.create!(pokemon_id: pokemon.id, ability_id: ability.id, is_hidden: false, slot: 1)

    get "/api/v3/pokemon", params: { q: "bulba" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/pokemon", params: { q: "bulba", include: "abilities" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    pokemon = Pokemon.find_by!(name: "bulbasaur")

    get "/api/v3/pokemon/#{pokemon.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/pokemon/#{pokemon.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
