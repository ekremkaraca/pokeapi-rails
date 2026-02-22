require "test_helper"

class Api::V3::PokemonColorControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokePokemonColor.delete_all
    %w[black blue brown gray green].each { |name| PokePokemonColor.create!(name: name) }
  end

  test "list supports pagination q filter sort and fields" do
    get "/api/v3/pokemon-color", params: { limit: 2, offset: 0, q: "bl", sort: "-name", fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 2, payload["count"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_equal "blue", payload["results"].first["name"]
  end

  test "list supports filter by name and and semantics with q" do
    get "/api/v3/pokemon-color", params: { q: "bl", filter: { name: "black" } }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 1, payload["count"]
    assert_equal "black", payload.dig("results", 0, "name")
  end

  test "show returns standardized payload" do
    color = PokePokemonColor.find_by!(name: "black")

    get "/api/v3/pokemon-color/#{color.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[id name url], payload.keys.sort
    assert_equal color.id, payload["id"]
  end

  test "show invalid token returns standardized not found envelope" do
    get "/api/v3/pokemon-color/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)
    assert_not_found_error_envelope(payload)
  end

  test "invalid query params return bad request" do
    get "/api/v3/pokemon-color", params: { fields: "name,unknown" }
    assert_response :bad_request
    get "/api/v3/pokemon-color", params: { include: "anything" }
    assert_response :bad_request
    get "/api/v3/pokemon-color", params: { sort: "url" }
    assert_response :bad_request
    get "/api/v3/pokemon-color", params: { filter: { id: "1" } }
    assert_response :bad_request
  end

  test "trailing slash and conditional get are supported" do
    color = PokePokemonColor.find_by!(name: "black")

    get "/api/v3/pokemon-color/"
    assert_response :success
    get "/api/v3/pokemon-color/#{color.id}/"
    assert_response :success

    get "/api/v3/pokemon-color", params: { q: "black" }
    etag = response.headers["ETag"]
    get "/api/v3/pokemon-color", params: { q: "black" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
  end
end
