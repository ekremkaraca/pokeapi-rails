require "test_helper"

class Api::V2::ContestTypeControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeContestType.delete_all

    %w[cool beauty cute smart tough].each do |name|
      PokeContestType.create!(name: name)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/contest-type", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/contest-type/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/contest-type/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/contest-type", params: { q: "bea" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 1, payload["count"]
    assert_equal [ "beauty" ], payload["results"].map { |record| record["name"] }
  end

  test "show supports retrieval by id and name" do
    contest_type = PokeContestType.find_by!(name: "cool")

    get "/api/v2/contest-type/#{contest_type.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal contest_type.id, payload["id"]
    assert_equal "cool", payload["name"]

    get "/api/v2/contest-type/COOL"
    assert_response :success
  end

  test "list and show accept trailing slash" do
    contest_type = PokeContestType.find_by!(name: "cool")

    get "/api/v2/contest-type/"
    assert_response :success

    get "/api/v2/contest-type/#{contest_type.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/contest-type/%2A%2A"

    assert_response :not_found
  end
end
