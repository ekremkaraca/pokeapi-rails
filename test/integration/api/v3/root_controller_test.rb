require "test_helper"

class Api::V3::RootControllerTest < ActionDispatch::IntegrationTest
  test "lists available api v3 endpoints" do
    get "/api/v3/"

    assert_response :success
    assert_equal "experimental", response.headers["X-API-Stability"]
    assert_observability_headers
    payload = JSON.parse(response.body)

    assert_equal %w[ability berry berry-firmness berry-flavor characteristic contest-effect contest-type egg-group encounter-condition encounter-condition-value encounter-method evolution-chain evolution-trigger gender generation growth-rate item item-attribute item-category item-fling-effect item-pocket language location location-area machine move move-ailment move-battle-style move-category move-damage-class move-learn-method move-target nature pal-park-area pokeathlon-stat pokedex pokemon pokemon-color pokemon-form pokemon-habitat pokemon-shape pokemon-species region stat super-contest-effect type version version-group], payload.keys.sort
    assert_match(%r{/api/v3/ability/$}, payload["ability"])
    assert_match(%r{/api/v3/evolution-chain/$}, payload["evolution-chain"])
    assert_match(%r{/api/v3/evolution-trigger/$}, payload["evolution-trigger"])
    assert_match(%r{/api/v3/egg-group/$}, payload["egg-group"])
    assert_match(%r{/api/v3/encounter-condition/$}, payload["encounter-condition"])
    assert_match(%r{/api/v3/encounter-condition-value/$}, payload["encounter-condition-value"])
    assert_match(%r{/api/v3/encounter-method/$}, payload["encounter-method"])
    assert_match(%r{/api/v3/berry/$}, payload["berry"])
    assert_match(%r{/api/v3/berry-firmness/$}, payload["berry-firmness"])
    assert_match(%r{/api/v3/berry-flavor/$}, payload["berry-flavor"])
    assert_match(%r{/api/v3/contest-type/$}, payload["contest-type"])
    assert_match(%r{/api/v3/contest-effect/$}, payload["contest-effect"])
    assert_match(%r{/api/v3/item-category/$}, payload["item-category"])
    assert_match(%r{/api/v3/item-pocket/$}, payload["item-pocket"])
    assert_match(%r{/api/v3/item-attribute/$}, payload["item-attribute"])
    assert_match(%r{/api/v3/item-fling-effect/$}, payload["item-fling-effect"])
    assert_match(%r{/api/v3/language/$}, payload["language"])
    assert_match(%r{/api/v3/location/$}, payload["location"])
    assert_match(%r{/api/v3/location-area/$}, payload["location-area"])
    assert_match(%r{/api/v3/machine/$}, payload["machine"])
    assert_match(%r{/api/v3/move-ailment/$}, payload["move-ailment"])
    assert_match(%r{/api/v3/move-battle-style/$}, payload["move-battle-style"])
    assert_match(%r{/api/v3/move-category/$}, payload["move-category"])
    assert_match(%r{/api/v3/move-damage-class/$}, payload["move-damage-class"])
    assert_match(%r{/api/v3/move-learn-method/$}, payload["move-learn-method"])
    assert_match(%r{/api/v3/move-target/$}, payload["move-target"])
    assert_match(%r{/api/v3/characteristic/$}, payload["characteristic"])
    assert_match(%r{/api/v3/stat/$}, payload["stat"])
    assert_match(%r{/api/v3/super-contest-effect/$}, payload["super-contest-effect"])
    assert_match(%r{/api/v3/pal-park-area/$}, payload["pal-park-area"])
    assert_match(%r{/api/v3/pokeathlon-stat/$}, payload["pokeathlon-stat"])
    assert_match(%r{/api/v3/pokedex/$}, payload["pokedex"])
    assert_match(%r{/api/v3/pokemon-color/$}, payload["pokemon-color"])
    assert_match(%r{/api/v3/pokemon-form/$}, payload["pokemon-form"])
    assert_match(%r{/api/v3/pokemon-habitat/$}, payload["pokemon-habitat"])
    assert_match(%r{/api/v3/pokemon-shape/$}, payload["pokemon-shape"])
    assert_match(%r{/api/v3/generation/$}, payload["generation"])
    assert_match(%r{/api/v3/growth-rate/$}, payload["growth-rate"])
    assert_match(%r{/api/v3/gender/$}, payload["gender"])
    assert_match(%r{/api/v3/nature/$}, payload["nature"])
    assert_match(%r{/api/v3/item/$}, payload["item"])
    assert_match(%r{/api/v3/move/$}, payload["move"])
    assert_match(%r{/api/v3/pokemon/$}, payload["pokemon"])
    assert_match(%r{/api/v3/pokemon-species/$}, payload["pokemon-species"])
    assert_match(%r{/api/v3/region/$}, payload["region"])
    assert_match(%r{/api/v3/type/$}, payload["type"])
    assert_match(%r{/api/v3/version/$}, payload["version"])
    assert_match(%r{/api/v3/version-group/$}, payload["version-group"])

    payload.each_value do |url|
      refute_match(%r{//$}, url)
    end
  end

  test "root is available with or without trailing slash" do
    get "/api/v3"
    assert_response :success
    assert_equal "experimental", response.headers["X-API-Stability"]
    assert_observability_headers

    get "/api/v3/"
    assert_response :success
    assert_equal "experimental", response.headers["X-API-Stability"]
    assert_observability_headers
  end
end
