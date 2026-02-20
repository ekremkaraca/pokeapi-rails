require "test_helper"

class Api::V3::PokemonSpeciesControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokePokemonSpecies.delete_all
    PokeGeneration.delete_all

    generation_i = PokeGeneration.create!(name: "generation-i", main_region_id: nil)
    generation_ii = PokeGeneration.create!(name: "generation-ii", main_region_id: nil)

    [
      { name: "bulbasaur", base_happiness: 70, capture_rate: 45, generation_id: generation_i.id, evolution_chain_id: 1, is_baby: false, is_legendary: false, is_mythical: false },
      { name: "ivysaur", base_happiness: 70, capture_rate: 45, generation_id: generation_i.id, evolution_chain_id: 1, is_baby: false, is_legendary: false, is_mythical: false },
      { name: "venusaur", base_happiness: 70, capture_rate: 45, generation_id: generation_i.id, evolution_chain_id: 1, is_baby: false, is_legendary: false, is_mythical: false },
      { name: "chikorita", base_happiness: 70, capture_rate: 45, generation_id: generation_ii.id, evolution_chain_id: 2, is_baby: false, is_legendary: false, is_mythical: false },
      { name: "bayleef", base_happiness: 70, capture_rate: 45, generation_id: generation_ii.id, evolution_chain_id: 2, is_baby: false, is_legendary: false, is_mythical: false }
    ].each do |attrs|
      PokePokemonSpecies.create!(attrs)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/pokemon-species", params: { limit: 3, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 3, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[id name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/pokemon-species/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/pokemon-species", params: { q: "saur" }

    assert_response :success
    payload = JSON.parse(response.body)
    names = payload["results"].map { |record| record["name"] }

    assert_equal 3, payload["count"]
    assert_includes names, "bulbasaur"
    assert_includes names, "ivysaur"
    assert_includes names, "venusaur"
  end

  test "list supports filter by name" do
    get "/api/v3/pokemon-species", params: { filter: { name: "bulbasaur" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "bulbasaur", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/pokemon-species", params: { q: "saur", filter: { name: "bulbasaur" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "bulbasaur", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/pokemon-species", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "venusaur", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/pokemon-species", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "list supports include generation" do
    get "/api/v3/pokemon-species", params: { q: "bulba", include: "generation" }
    assert_response :success
    payload = JSON.parse(response.body)

    result = payload.fetch("results").first
    assert_equal "bulbasaur", result["name"]
    assert_equal "generation-i", result.dig("generation", "name")
    assert_match(%r{/api/v2/generation/\d+/$}, result.dig("generation", "url"))
  end

  test "show returns species payload with standardized keys" do
    species = PokePokemonSpecies.find_by!(name: "bulbasaur")

    get "/api/v3/pokemon-species/#{species.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[base_happiness capture_rate evolution_chain_id generation_id id is_baby is_legendary is_mythical name url], payload.keys.sort
    assert_equal species.id, payload["id"]
    assert_equal "bulbasaur", payload["name"]
    assert_equal 70, payload["base_happiness"]
    assert_match(%r{/api/v3/pokemon-species/#{species.id}/$}, payload["url"])
  end

  test "show supports include generation" do
    species = PokePokemonSpecies.find_by!(name: "bulbasaur")

    get "/api/v3/pokemon-species/#{species.id}", params: { include: "generation" }
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal "generation-i", payload.dig("generation", "name")
    assert_match(%r{/api/v2/generation/\d+/$}, payload.dig("generation", "url"))
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/pokemon-species/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_equal "not_found", payload.dig("error", "code")
    assert_equal "Resource not found", payload.dig("error", "message")
    assert_kind_of Hash, payload.dig("error", "details")
    assert_kind_of String, payload.dig("error", "request_id")
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/pokemon-species", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "fields", payload.dig("error", "details", "param")
    assert_equal ["unknown"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/pokemon-species", params: { include: "unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "include", payload.dig("error", "details", "param")
    assert_equal ["unknown"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/pokemon-species", params: { sort: "capture_rate" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "sort", payload.dig("error", "details", "param")
    assert_equal ["capture_rate"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/pokemon-species", params: { filter: { generation_id: "1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "filter", payload.dig("error", "details", "param")
    assert_equal ["generation_id"], payload.dig("error", "details", "invalid_values")
  end

  test "list and show accept trailing slash" do
    species = PokePokemonSpecies.find_by!(name: "bulbasaur")

    get "/api/v3/pokemon-species/"
    assert_response :success

    get "/api/v3/pokemon-species/#{species.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/pokemon-species", params: { limit: 3, offset: 0, q: "saur" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/pokemon-species", params: { limit: 3, offset: 0, q: "saur" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    species = PokePokemonSpecies.find_by!(name: "bulbasaur")

    get "/api/v3/pokemon-species/#{species.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/pokemon-species/#{species.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "list etag varies by sort parameter" do
    get "/api/v3/pokemon-species", params: { limit: 3, sort: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/pokemon-species", params: { limit: 3, sort: "-name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "list etag varies by include parameter" do
    get "/api/v3/pokemon-species", params: { q: "bulba" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/pokemon-species", params: { q: "bulba", include: "generation" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    species = PokePokemonSpecies.find_by!(name: "bulbasaur")

    get "/api/v3/pokemon-species/#{species.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/pokemon-species/#{species.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
