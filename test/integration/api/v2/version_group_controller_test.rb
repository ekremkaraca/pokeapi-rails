require "test_helper"

class Api::V2::VersionGroupControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeVersionGroup.delete_all

    %w[red-blue yellow gold-silver crystal ruby-sapphire].each do |name|
      PokeVersionGroup.create!(name: name)
    end

    25.times do |idx|
      PokeVersionGroup.create!(name: "version-group-#{idx + 1}")
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/version-group", params: { limit: 5, offset: 2 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 30, payload["count"]
    assert_equal 5, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/version-group/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/version-group/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/version-group", params: { q: "silver" }

    assert_response :success
    payload = JSON.parse(response.body)
    names = payload["results"].map { |record| record["name"] }

    assert_equal 1, payload["count"]
    assert_equal [ "gold-silver" ], names
  end

  test "show supports retrieval by id and name" do
    vg = PokeVersionGroup.find_by!(name: "red-blue")

    get "/api/v2/version-group/#{vg.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[generation id move_learn_methods name order pokedexes regions versions], payload.keys.sort
    assert_equal vg.id, payload["id"]
    assert_equal "red-blue", payload["name"]
    assert_nil payload["generation"]
    assert_nil payload["order"]
    assert_equal [], payload["move_learn_methods"]
    assert_equal [], payload["pokedexes"]
    assert_equal [], payload["regions"]
    assert_equal [], payload["versions"]

    get "/api/v2/version-group/RED-BLUE"
    assert_response :success
  end

test "show query count stays within budget" do
  query_count = capture_select_query_count do
    get "/api/v2/version-group/red-blue"
    assert_response :success
  end

  assert_operator query_count, :<=, 14
end

  test "list and show accept trailing slash" do
    vg = PokeVersionGroup.find_by!(name: "red-blue")

    get "/api/v2/version-group/"
    assert_response :success

    get "/api/v2/version-group/#{vg.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v2/version-group", params: { limit: 2, offset: 0 }
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/version-group", params: { limit: 2, offset: 0 }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    vg = PokeVersionGroup.find_by!(name: "red-blue")
    get "/api/v2/version-group/#{vg.id}"
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/version-group/#{vg.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/version-group/%2A%2A"

    assert_response :not_found
  end
end
