require "test_helper"

class Api::V2::PokeathlonStatControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokePokeathlonStat.delete_all

    %w[speed power skill stamina jump].each do |name|
      PokePokeathlonStat.create!(name: name)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/pokeathlon-stat", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/pokeathlon-stat/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/pokeathlon-stat", params: { q: "sta" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 1, payload["count"]
    assert_equal [ "stamina" ], payload["results"].map { |r| r["name"] }
  end

  test "show supports retrieval by id and name" do
    stat = PokePokeathlonStat.find_by!(name: "speed")

    get "/api/v2/pokeathlon-stat/#{stat.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal stat.id, payload["id"]
    assert_equal "speed", payload["name"]

    get "/api/v2/pokeathlon-stat/SPEED"
    assert_response :success
  end

  test "show query count stays within budget" do
    query_count = capture_select_query_count do
      get "/api/v2/pokeathlon-stat/speed"
      assert_response :success
    end

    assert_operator query_count, :<=, 14
  end

test "list supports conditional get with etag" do
    get "/api/v2/pokeathlon-stat", params: { limit: 2, offset: 0 }
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/pokeathlon-stat", params: { limit: 2, offset: 0 }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    stat = PokePokeathlonStat.find_by!(name: "speed")
    get "/api/v2/pokeathlon-stat/#{stat.id}"
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/pokeathlon-stat/#{stat.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end
end
