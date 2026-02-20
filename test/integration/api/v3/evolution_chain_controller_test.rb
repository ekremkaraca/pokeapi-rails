require "test_helper"

class Api::V3::EvolutionChainControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokePokemonSpecies.delete_all
    PokeEvolutionChain.delete_all

    chain_one = PokeEvolutionChain.create!(baby_trigger_item_id: nil)
    chain_two = PokeEvolutionChain.create!(baby_trigger_item_id: 2)
    chain_three = PokeEvolutionChain.create!(baby_trigger_item_id: nil)

    [
      { name: "bulbasaur", evolution_chain_id: chain_one.id },
      { name: "ivysaur", evolution_chain_id: chain_one.id },
      { name: "venusaur", evolution_chain_id: chain_one.id },
      { name: "charmander", evolution_chain_id: chain_two.id },
      { name: "chikorita", evolution_chain_id: chain_three.id }
    ].each do |attrs|
      PokePokemonSpecies.create!(attrs)
    end
  end

  test "list returns paginated summary data with id and url" do
    get "/api/v3/evolution-chain", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 3, payload["count"]
    assert_equal 2, payload["results"].length
    assert_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[id url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/evolution-chain/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter over chain species names" do
    get "/api/v3/evolution-chain", params: { q: "saur" }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal [ PokeEvolutionChain.order(:id).first.id ], payload.fetch("results").map { |item| item["id"] }
  end

  test "list supports filter by species name" do
    get "/api/v3/evolution-chain", params: { filter: { name: "chikorita" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    chain_id = PokePokemonSpecies.find_by!(name: "chikorita").evolution_chain_id
    assert_equal chain_id, payload.dig("results", 0, "id")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/evolution-chain", params: { q: "char", filter: { name: "charmander" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    chain_id = PokePokemonSpecies.find_by!(name: "charmander").evolution_chain_id
    assert_equal chain_id, payload.dig("results", 0, "id")
  end

  test "list supports sort parameter" do
    get "/api/v3/evolution-chain", params: { sort: "-id" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal PokeEvolutionChain.maximum(:id), payload.fetch("results").first.fetch("id")
  end

  test "list supports fields filter" do
    get "/api/v3/evolution-chain", params: { limit: 1, fields: "url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal [ "url" ], payload["results"].first.keys.sort
  end

  test "list supports include pokemon_species" do
    get "/api/v3/evolution-chain", params: { q: "bulba", include: "pokemon_species" }
    assert_response :success
    payload = JSON.parse(response.body)

    result = payload.fetch("results").first
    species_names = result.fetch("pokemon_species").map { |species| species["name"] }
    assert_equal "bulbasaur", species_names.first
    assert_includes species_names, "ivysaur"
    assert_match(%r{/api/v3/pokemon-species/\d+/$}, result.dig("pokemon_species", 0, "url"))
  end

  test "show returns chain payload with standardized keys" do
    chain = PokeEvolutionChain.order(:id).second

    get "/api/v3/evolution-chain/#{chain.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[baby_trigger_item_id id url], payload.keys.sort
    assert_equal chain.id, payload["id"]
    assert_equal 2, payload["baby_trigger_item_id"]
    assert_match(%r{/api/v3/evolution-chain/#{chain.id}/$}, payload["url"])
  end

  test "show supports include pokemon_species" do
    chain = PokeEvolutionChain.order(:id).first

    get "/api/v3/evolution-chain/#{chain.id}", params: { include: "pokemon_species" }
    assert_response :success
    payload = JSON.parse(response.body)

    names = payload.fetch("pokemon_species").map { |species| species["name"] }
    assert_equal %w[bulbasaur ivysaur venusaur], names
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/evolution-chain/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_equal "not_found", payload.dig("error", "code")
    assert_equal "Resource not found", payload.dig("error", "message")
    assert_kind_of Hash, payload.dig("error", "details")
    assert_kind_of String, payload.dig("error", "request_id")
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/evolution-chain", params: { fields: "id,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "fields", payload.dig("error", "details", "param")
    assert_equal [ "unknown" ], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/evolution-chain", params: { include: "unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "include", payload.dig("error", "details", "param")
    assert_equal [ "unknown" ], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/evolution-chain", params: { sort: "name" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "sort", payload.dig("error", "details", "param")
    assert_equal [ "name" ], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/evolution-chain", params: { filter: { id: "1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "filter", payload.dig("error", "details", "param")
    assert_equal [ "id" ], payload.dig("error", "details", "invalid_values")
  end

  test "list and show accept trailing slash" do
    chain = PokeEvolutionChain.order(:id).first

    get "/api/v3/evolution-chain/"
    assert_response :success

    get "/api/v3/evolution-chain/#{chain.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/evolution-chain", params: { limit: 2, offset: 0, q: "saur" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/evolution-chain", params: { limit: 2, offset: 0, q: "saur" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    chain = PokeEvolutionChain.order(:id).first

    get "/api/v3/evolution-chain/#{chain.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/evolution-chain/#{chain.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "list etag varies by sort parameter" do
    get "/api/v3/evolution-chain", params: { limit: 2, sort: "id" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/evolution-chain", params: { limit: 2, sort: "-id" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "list etag varies by include parameter" do
    get "/api/v3/evolution-chain", params: { q: "saur" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/evolution-chain", params: { q: "saur", include: "pokemon_species" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    chain = PokeEvolutionChain.order(:id).first

    get "/api/v3/evolution-chain/#{chain.id}", params: { fields: "id" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/evolution-chain/#{chain.id}", params: { fields: "id,url" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
