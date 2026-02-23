require "test_helper"

class Api::V2::EvolutionTriggerControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeEvolutionTrigger.delete_all

    %w[level-up trade use-item shed].each do |name|
      PokeEvolutionTrigger.create!(name: name)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/evolution-trigger", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 4, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/evolution-trigger/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/evolution-trigger", params: { q: "item" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 1, payload["count"]
    assert_equal [ "use-item" ], payload["results"].map { |record| record["name"] }
  end

  test "show supports retrieval by id and name" do
    trigger = PokeEvolutionTrigger.find_by!(name: "level-up")

    get "/api/v2/evolution-trigger/#{trigger.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal trigger.id, payload["id"]
    assert_equal "level-up", payload["name"]

    get "/api/v2/evolution-trigger/LEVEL-UP"
    assert_response :success
  end

  test "show query count stays within budget" do
    query_count = capture_select_query_count do
      get "/api/v2/evolution-trigger/level-up"
      assert_response :success
    end

    assert_operator query_count, :<=, 14
  end

  test "list supports conditional get with etag" do
    get "/api/v2/evolution-trigger", params: { limit: 2, offset: 0 }
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/evolution-trigger", params: { limit: 2, offset: 0 }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    trigger = PokeEvolutionTrigger.find_by!(name: "level-up")
    get "/api/v2/evolution-trigger/#{trigger.id}"
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/evolution-trigger/#{trigger.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/evolution-trigger/%2A%2A"

    assert_response :not_found
  end
end
