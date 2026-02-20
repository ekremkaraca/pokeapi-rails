require "test_helper"

class Api::V3::PokemonFormControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokePokemonForm.delete_all

    [
      { name: "bulbasaur", form_name: nil, pokemon_id: 1, introduced_in_version_group_id: 28, is_default: true, is_battle_only: false, is_mega: false, form_order: 1, sort_order: 1 },
      { name: "venusaur-mega", form_name: "mega", pokemon_id: 10033, introduced_in_version_group_id: 15, is_default: false, is_battle_only: true, is_mega: true, form_order: 2, sort_order: 4 },
      { name: "charizard-mega-x", form_name: "mega-x", pokemon_id: 10034, introduced_in_version_group_id: 15, is_default: false, is_battle_only: true, is_mega: true, form_order: 2, sort_order: 7 }
    ].each { |attrs| PokePokemonForm.create!(attrs) }
  end

  test "list returns paginated summary data with expected keys" do
    get "/api/v3/pokemon-form", params: { limit: 2, offset: 0 }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 3, payload["count"]
    assert_equal 2, payload["results"].length
    assert_equal %w[form_name form_order id introduced_in_version_group_id is_battle_only is_default is_mega name pokemon_id sort_order url], payload["results"].first.keys.sort
  end

  test "list supports q filter filter[name] sort and fields" do
    get "/api/v3/pokemon-form", params: {
      q: "mega",
      filter: { name: "venusaur-mega" },
      sort: "-sort_order",
      fields: "name,url,sort_order"
    }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 1, payload["count"]
    assert_equal %w[name sort_order url], payload["results"].first.keys.sort
  end

  test "show returns standardized payload" do
    form = PokePokemonForm.find_by!(name: "venusaur-mega")

    get "/api/v3/pokemon-form/#{form.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[form_name form_order id introduced_in_version_group_id is_battle_only is_default is_mega name pokemon_id sort_order url], payload.keys.sort
  end

  test "show invalid token and invalid query parameters" do
    get "/api/v3/pokemon-form/not-a-number"
    assert_response :not_found

    get "/api/v3/pokemon-form", params: { fields: "name,unknown" }
    assert_response :bad_request
    get "/api/v3/pokemon-form", params: { include: "anything" }
    assert_response :bad_request
    get "/api/v3/pokemon-form", params: { sort: "form_name" }
    assert_response :bad_request
    get "/api/v3/pokemon-form", params: { filter: { id: "1" } }
    assert_response :bad_request
  end

  test "trailing slash and conditional get are supported" do
    form = PokePokemonForm.find_by!(name: "venusaur-mega")

    get "/api/v3/pokemon-form/"
    assert_response :success
    get "/api/v3/pokemon-form/#{form.id}/"
    assert_response :success

    get "/api/v3/pokemon-form/#{form.id}"
    etag = response.headers["ETag"]
    get "/api/v3/pokemon-form/#{form.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
  end
end
