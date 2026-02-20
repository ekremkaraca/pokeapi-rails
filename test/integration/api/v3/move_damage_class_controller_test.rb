require "test_helper"

class Api::V3::MoveDamageClassControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeMoveDamageClass.delete_all

    %w[status physical special].each do |name|
      PokeMoveDamageClass.create!(name: name)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/move-damage-class", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 3, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["previous"]
    assert_equal %w[id name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/move-damage-class/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/move-damage-class", params: { q: "spec" }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "special", payload.dig("results", 0, "name")
  end

  test "list supports filter by name" do
    get "/api/v3/move-damage-class", params: { filter: { name: "status" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "status", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/move-damage-class", params: { q: "spec", filter: { name: "special" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "special", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/move-damage-class", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "status", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/move-damage-class", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "show returns move-damage-class payload with standardized keys" do
    mdc = PokeMoveDamageClass.find_by!(name: "status")

    get "/api/v3/move-damage-class/#{mdc.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[id name url], payload.keys.sort
    assert_equal mdc.id, payload["id"]
    assert_equal "status", payload["name"]
    assert_match(%r{/api/v3/move-damage-class/#{mdc.id}/$}, payload["url"])
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/move-damage-class/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_equal "not_found", payload.dig("error", "code")
    assert_equal "Resource not found", payload.dig("error", "message")
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/move-damage-class", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)
    assert_equal "fields", payload.dig("error", "details", "param")
    assert_equal ["unknown"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/move-damage-class", params: { include: "anything" }

    assert_response :bad_request
    payload = JSON.parse(response.body)
    assert_equal "include", payload.dig("error", "details", "param")
    assert_equal ["anything"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/move-damage-class", params: { sort: "url" }

    assert_response :bad_request
    payload = JSON.parse(response.body)
    assert_equal "sort", payload.dig("error", "details", "param")
    assert_equal ["url"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/move-damage-class", params: { filter: { id: "1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)
    assert_equal "filter", payload.dig("error", "details", "param")
    assert_equal ["id"], payload.dig("error", "details", "invalid_values")
  end

  test "list and show accept trailing slash" do
    mdc = PokeMoveDamageClass.find_by!(name: "status")

    get "/api/v3/move-damage-class/"
    assert_response :success

    get "/api/v3/move-damage-class/#{mdc.id}/"
    assert_response :success
  end
end
