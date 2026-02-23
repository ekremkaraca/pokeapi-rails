require "test_helper"

class Api::V2::GenerationControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeGeneration.delete_all

    %w[generation-i generation-ii generation-iii generation-iv generation-v].each do |name|
      PokeGeneration.create!(name: name)
    end

    25.times do |idx|
      PokeGeneration.create!(name: "generation-#{idx + 10}")
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/generation", params: { limit: 5, offset: 2 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 30, payload["count"]
    assert_equal 5, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/generation/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/generation/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/generation", params: { q: "iii" }

    assert_response :success
    payload = JSON.parse(response.body)
    names = payload["results"].map { |record| record["name"] }

    assert_equal 1, payload["count"]
    assert_equal [ "generation-iii" ], names
  end

  test "show supports retrieval by id and name" do
    generation = PokeGeneration.find_by!(name: "generation-i")

    get "/api/v2/generation/#{generation.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[abilities id main_region moves name names pokemon_species types version_groups], payload.keys.sort
    assert_equal generation.id, payload["id"]
    assert_equal "generation-i", payload["name"]
    assert_equal [], payload["abilities"]
    assert_equal [], payload["moves"]
    assert_equal [], payload["names"]
    assert_equal [], payload["pokemon_species"]
    assert_equal [], payload["types"]
    assert_equal [], payload["version_groups"]
    assert_nil payload["main_region"]

    get "/api/v2/generation/GENERATION-I"
    assert_response :success
  end

test "show query count stays within budget" do
  query_count = capture_select_query_count do
    get "/api/v2/generation/generation-i"
    assert_response :success
  end

  assert_operator query_count, :<=, 14
end

  test "list and show accept trailing slash" do
    generation = PokeGeneration.find_by!(name: "generation-i")

    get "/api/v2/generation/"
    assert_response :success

    get "/api/v2/generation/#{generation.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v2/generation", params: { limit: 2, offset: 0 }
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/generation", params: { limit: 2, offset: 0 }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    generation = PokeGeneration.find_by!(name: "generation-i")
    get "/api/v2/generation/#{generation.id}"
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/generation/#{generation.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/generation/%2A%2A"

    assert_response :not_found
  end
end
