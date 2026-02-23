require "test_helper"

class Api::V2::EggGroupControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeEggGroup.delete_all

    %w[monster water-1 bug fairy human-like].each do |name|
      PokeEggGroup.create!(name: name)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/egg-group", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/egg-group/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/egg-group/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/egg-group", params: { q: "water" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 1, payload["count"]
    assert_equal [ "water-1" ], payload["results"].map { |record| record["name"] }
  end

  test "show supports retrieval by id and name" do
    egg_group = PokeEggGroup.find_by!(name: "monster")

    get "/api/v2/egg-group/#{egg_group.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal egg_group.id, payload["id"]
    assert_equal "monster", payload["name"]

    get "/api/v2/egg-group/MONSTER"
    assert_response :success
  end

test "show query count stays within budget" do
  query_count = capture_select_query_count do
    get "/api/v2/egg-group/monster"
    assert_response :success
  end

  assert_operator query_count, :<=, 14
end

  test "list and show accept trailing slash" do
    egg_group = PokeEggGroup.find_by!(name: "monster")

    get "/api/v2/egg-group/"
    assert_response :success

    get "/api/v2/egg-group/#{egg_group.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v2/egg-group", params: { limit: 2, offset: 0 }
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/egg-group", params: { limit: 2, offset: 0 }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    egg_group = PokeEggGroup.find_by!(name: "monster")
    get "/api/v2/egg-group/#{egg_group.id}"
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/egg-group/#{egg_group.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/egg-group/%2A%2A"

    assert_response :not_found
  end
end
