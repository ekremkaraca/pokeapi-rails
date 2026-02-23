require "test_helper"

class Api::V2::StatControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeStat.delete_all

    [
      { name: "hp", is_battle_only: false },
      { name: "attack", is_battle_only: false },
      { name: "defense", is_battle_only: false },
      { name: "special-attack", is_battle_only: false },
      { name: "speed", is_battle_only: false }
    ].each do |attrs|
      PokeStat.create!(attrs)
    end

    25.times do |idx|
      PokeStat.create!(name: "stat-#{idx + 1}", is_battle_only: (idx % 2).zero?)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/stat", params: { limit: 5, offset: 2 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 30, payload["count"]
    assert_equal 5, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/stat/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/stat/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/stat", params: { q: "attack" }

    assert_response :success
    payload = JSON.parse(response.body)
    names = payload["results"].map { |record| record["name"] }

    assert_equal 2, payload["count"]
    assert_includes names, "attack"
    assert_includes names, "special-attack"
  end

  test "show supports retrieval by id and name" do
    stat = PokeStat.find_by!(name: "hp")

    get "/api/v2/stat/#{stat.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal stat.id, payload["id"]
    assert_equal "hp", payload["name"]
    assert_equal false, payload["is_battle_only"]

    get "/api/v2/stat/HP"
    assert_response :success
  end

test "show query count stays within budget" do
  query_count = capture_select_query_count do
    get "/api/v2/stat/hp"
    assert_response :success
  end

  assert_operator query_count, :<=, 14
end

  test "list and show accept trailing slash" do
    stat = PokeStat.find_by!(name: "hp")

    get "/api/v2/stat/"
    assert_response :success

    get "/api/v2/stat/#{stat.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v2/stat", params: { limit: 2, offset: 0 }
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/stat", params: { limit: 2, offset: 0 }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    stat = PokeStat.find_by!(name: "hp")
    get "/api/v2/stat/#{stat.id}"
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/stat/#{stat.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/stat/%2A%2A"

    assert_response :not_found
  end
end
