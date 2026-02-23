require "test_helper"

class Api::V2::LanguageControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeLanguage.delete_all

    [
      { name: "en", official: true },
      { name: "ja", official: true },
      { name: "ko", official: true },
      { name: "fr", official: true },
      { name: "de", official: true }
    ].each do |attrs|
      PokeLanguage.create!(attrs)
    end

    25.times do |idx|
      PokeLanguage.create!(name: "lang-#{idx + 1}", official: (idx % 2).zero?)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/language", params: { limit: 5, offset: 2 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 30, payload["count"]
    assert_equal 5, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/language/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/language/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/language", params: { q: "ja" }

    assert_response :success
    payload = JSON.parse(response.body)
    names = payload["results"].map { |record| record["name"] }

    assert_equal 1, payload["count"]
    assert_equal [ "ja" ], names
  end

  test "show supports retrieval by id and name" do
    language = PokeLanguage.find_by!(name: "en")

    get "/api/v2/language/#{language.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal language.id, payload["id"]
    assert_equal "en", payload["name"]
    assert_equal true, payload["official"]

    get "/api/v2/language/EN"
    assert_response :success
  end

test "show query count stays within budget" do
  query_count = capture_select_query_count do
    get "/api/v2/language/en"
    assert_response :success
  end

  assert_operator query_count, :<=, 14
end

  test "list and show accept trailing slash" do
    language = PokeLanguage.find_by!(name: "en")

    get "/api/v2/language/"
    assert_response :success

    get "/api/v2/language/#{language.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v2/language", params: { limit: 2, offset: 0 }
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/language", params: { limit: 2, offset: 0 }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    language = PokeLanguage.find_by!(name: "en")
    get "/api/v2/language/#{language.id}"
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/language/#{language.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/language/%2A%2A"

    assert_response :not_found
  end
end
