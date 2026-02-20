require "test_helper"

class Api::V3::ContestEffectControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeMove.delete_all
    PokeContestEffect.delete_all

    first = PokeContestEffect.create!(appeal: 4, jam: 0)
    second = PokeContestEffect.create!(appeal: 1, jam: 3)
    third = PokeContestEffect.create!(appeal: 6, jam: 0)

    PokeMove.create!(name: "pound", contest_effect_id: first.id)
    PokeMove.create!(name: "karate-chop", contest_effect_id: second.id)
    PokeMove.create!(name: "double-slap", contest_effect_id: third.id)
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/contest-effect", params: { limit: 2, offset: 0 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 3, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_nil payload["previous"]
    assert_equal %w[appeal id jam name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/contest-effect/\d+/$}, payload["results"].first["url"])
    assert_match(/\Acontest-effect-\d+\z/, payload["results"].first["name"])
  end

  test "list supports q filter over synthetic name" do
    contest_effect = PokeContestEffect.order(:id).first
    get "/api/v3/contest-effect", params: { q: contest_effect.id.to_s }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal contest_effect.id, payload.dig("results", 0, "id")
  end

  test "list supports filter by synthetic name" do
    contest_effect = PokeContestEffect.order(:id).second
    get "/api/v3/contest-effect", params: { filter: { name: "contest-effect-#{contest_effect.id}" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal contest_effect.id, payload.dig("results", 0, "id")
  end

  test "list combines q and filter with and semantics" do
    contest_effect = PokeContestEffect.order(:id).second
    get "/api/v3/contest-effect", params: { q: contest_effect.id.to_s, filter: { name: "contest-effect-#{contest_effect.id}" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal contest_effect.id, payload.dig("results", 0, "id")
  end

  test "list supports sort parameter" do
    get "/api/v3/contest-effect", params: { sort: "-appeal" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 6, payload.fetch("results").first.fetch("appeal")
  end

  test "list supports fields filter" do
    get "/api/v3/contest-effect", params: { limit: 1, fields: "name,url,appeal" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[appeal name url], payload["results"].first.keys.sort
  end

  test "list supports include moves" do
    contest_effect = PokeContestEffect.order(:id).first

    get "/api/v3/contest-effect", params: { filter: { name: "contest-effect-#{contest_effect.id}" }, include: "moves" }
    assert_response :success
    payload = JSON.parse(response.body)

    result = payload.fetch("results").first
    assert_equal contest_effect.id, result["id"]
    assert_equal [ "pound" ], result.fetch("moves").map { |move| move.fetch("name") }
    assert_match(%r{/api/v3/move/\d+/$}, result.dig("moves", 0, "url"))
  end

  test "show returns contest effect payload with standardized keys" do
    contest_effect = PokeContestEffect.order(:id).first

    get "/api/v3/contest-effect/#{contest_effect.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[appeal id jam name url], payload.keys.sort
    assert_equal contest_effect.id, payload["id"]
    assert_equal 4, payload["appeal"]
    assert_equal 0, payload["jam"]
    assert_match(%r{/api/v3/contest-effect/#{contest_effect.id}/$}, payload["url"])
  end

  test "show supports include moves" do
    contest_effect = PokeContestEffect.order(:id).second

    get "/api/v3/contest-effect/#{contest_effect.id}", params: { include: "moves" }
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal [ "karate-chop" ], payload.fetch("moves").map { |move| move.fetch("name") }
    assert_match(%r{/api/v3/move/\d+/$}, payload.dig("moves", 0, "url"))
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/contest-effect/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_equal "not_found", payload.dig("error", "code")
    assert_equal "Resource not found", payload.dig("error", "message")
    assert_kind_of Hash, payload.dig("error", "details")
    assert_kind_of String, payload.dig("error", "request_id")
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/contest-effect", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "fields", payload.dig("error", "details", "param")
    assert_equal [ "unknown" ], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/contest-effect", params: { include: "unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "include", payload.dig("error", "details", "param")
    assert_equal [ "unknown" ], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/contest-effect", params: { sort: "name" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "sort", payload.dig("error", "details", "param")
    assert_equal [ "name" ], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/contest-effect", params: { filter: { appeal: "1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "filter", payload.dig("error", "details", "param")
    assert_equal [ "appeal" ], payload.dig("error", "details", "invalid_values")
  end

  test "list and show accept trailing slash" do
    contest_effect = PokeContestEffect.order(:id).first

    get "/api/v3/contest-effect/"
    assert_response :success

    get "/api/v3/contest-effect/#{contest_effect.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    contest_effect = PokeContestEffect.order(:id).first
    get "/api/v3/contest-effect", params: { limit: 2, offset: 0, q: contest_effect.id.to_s }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/contest-effect", params: { limit: 2, offset: 0, q: contest_effect.id.to_s }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    contest_effect = PokeContestEffect.order(:id).first

    get "/api/v3/contest-effect/#{contest_effect.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/contest-effect/#{contest_effect.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "list etag varies by include parameter" do
    contest_effect = PokeContestEffect.order(:id).first
    get "/api/v3/contest-effect", params: { q: contest_effect.id.to_s }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/contest-effect", params: { q: contest_effect.id.to_s, include: "moves" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    contest_effect = PokeContestEffect.order(:id).first

    get "/api/v3/contest-effect/#{contest_effect.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/contest-effect/#{contest_effect.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
