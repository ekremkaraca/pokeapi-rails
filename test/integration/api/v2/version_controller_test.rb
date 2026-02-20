require "test_helper"

class Api::V2::VersionControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeVersion.delete_all

    %w[red blue yellow gold silver].each do |name|
      PokeVersion.create!(name: name)
    end

    25.times do |idx|
      PokeVersion.create!(name: "version-#{idx + 1}")
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/version", params: { limit: 5, offset: 2 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 30, payload["count"]
    assert_equal 5, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/version/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/version/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/version", params: { q: "ell" }

    assert_response :success
    payload = JSON.parse(response.body)
    names = payload["results"].map { |record| record["name"] }

    assert_equal 1, payload["count"]
    assert_equal [ "yellow" ], names
  end

  test "show supports retrieval by id and name" do
    version = PokeVersion.find_by!(name: "red")

    get "/api/v2/version/#{version.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal version.id, payload["id"]
    assert_equal "red", payload["name"]

    get "/api/v2/version/RED"
    assert_response :success
  end

  test "list and show accept trailing slash" do
    version = PokeVersion.find_by!(name: "red")

    get "/api/v2/version/"
    assert_response :success

    get "/api/v2/version/#{version.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/version/%2A%2A"

    assert_response :not_found
  end
end
