require "test_helper"

class Api::V2::GenderControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeGender.delete_all

    %w[female male genderless].each do |name|
      PokeGender.create!(name: name)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/gender", params: { limit: 2, offset: 0 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 3, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/gender/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/gender", params: { q: "male" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 2, payload["count"]
  end

  test "show supports retrieval by id and name" do
    gender = PokeGender.find_by!(name: "female")

    get "/api/v2/gender/#{gender.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal gender.id, payload["id"]
    assert_equal "female", payload["name"]

    get "/api/v2/gender/FEMALE"
    assert_response :success
  end

  test "show query count stays within budget" do
    query_count = capture_select_query_count do
      get "/api/v2/gender/female"
      assert_response :success
    end

    assert_operator query_count, :<=, 14
  end

  test "list supports conditional get with etag" do
    get "/api/v2/gender", params: { limit: 2, offset: 0 }
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/gender", params: { limit: 2, offset: 0 }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    gender = PokeGender.find_by!(name: "female")
    get "/api/v2/gender/#{gender.id}"
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/gender/#{gender.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/gender/%2A%2A"

    assert_response :not_found
  end
end
