require "test_helper"

class Api::V2::PokemonFormControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokePokemonForm.delete_all

    [
      { name: "bulbasaur", form_name: nil, pokemon_id: 1, introduced_in_version_group_id: 28, is_default: true, is_battle_only: false, is_mega: false, form_order: 1, sort_order: 1 },
      { name: "venusaur", form_name: nil, pokemon_id: 3, introduced_in_version_group_id: 28, is_default: true, is_battle_only: false, is_mega: false, form_order: 1, sort_order: 3 },
      { name: "venusaur-mega", form_name: "mega", pokemon_id: 10033, introduced_in_version_group_id: 15, is_default: false, is_battle_only: true, is_mega: true, form_order: 2, sort_order: 4 },
      { name: "charizard", form_name: nil, pokemon_id: 6, introduced_in_version_group_id: 28, is_default: true, is_battle_only: false, is_mega: false, form_order: 1, sort_order: 6 },
      { name: "charizard-mega-x", form_name: "mega-x", pokemon_id: 10034, introduced_in_version_group_id: 15, is_default: false, is_battle_only: true, is_mega: true, form_order: 2, sort_order: 7 }
    ].each do |attrs|
      PokePokemonForm.create!(attrs)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/pokemon-form", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/pokemon-form/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/pokemon-form/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/pokemon-form", params: { q: "mega" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 2, payload["count"]
  end

  test "show supports retrieval by id and name" do
    pokemon_form = PokePokemonForm.find_by!(name: "venusaur-mega")

    get "/api/v2/pokemon-form/#{pokemon_form.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal pokemon_form.id, payload["id"]
    assert_equal "venusaur-mega", payload["name"]
    assert_equal "mega", payload["form_name"]
    assert_equal true, payload["is_mega"]
    assert_equal true, payload["is_battle_only"]

    get "/api/v2/pokemon-form/VENUSAUR-MEGA"
    assert_response :success
  end

test "show query count stays within budget" do
  query_count = capture_select_query_count do
    get "/api/v2/pokemon-form/venusaur-mega"
    assert_response :success
  end

  assert_operator query_count, :<=, 14
end

  test "list and show accept trailing slash" do
    pokemon_form = PokePokemonForm.find_by!(name: "venusaur-mega")

    get "/api/v2/pokemon-form/"
    assert_response :success

    get "/api/v2/pokemon-form/#{pokemon_form.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v2/pokemon-form", params: { limit: 2, offset: 0 }
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/pokemon-form", params: { limit: 2, offset: 0 }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    pokemon_form = PokePokemonForm.find_by!(name: "venusaur-mega")
    get "/api/v2/pokemon-form/#{pokemon_form.id}"
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/pokemon-form/#{pokemon_form.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/pokemon-form/%2A%2A"

    assert_response :not_found
  end
end
