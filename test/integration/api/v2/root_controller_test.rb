require "test_helper"

class Api::V2::RootControllerTest < ActionDispatch::IntegrationTest
  test "lists available api v2 endpoints" do
    get "/api/v2/"

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[ability berry berry-firmness berry-flavor characteristic contest-effect contest-type egg-group encounter-condition encounter-condition-value encounter-method evolution-chain evolution-trigger gender generation growth-rate item item-attribute item-category item-fling-effect item-pocket language location location-area machine move move-ailment move-battle-style move-category move-damage-class move-learn-method move-target nature pal-park-area pokeathlon-stat pokedex pokemon pokemon-color pokemon-form pokemon-habitat pokemon-shape pokemon-species region stat super-contest-effect type version version-group], payload.keys.sort
    assert_match(%r{/api/v2/ability/$}, payload["ability"])
    assert_match(%r{/api/v2/berry/$}, payload["berry"])
    assert_match(%r{/api/v2/berry-firmness/$}, payload["berry-firmness"])
    assert_match(%r{/api/v2/berry-flavor/$}, payload["berry-flavor"])
    assert_match(%r{/api/v2/characteristic/$}, payload["characteristic"])
    assert_match(%r{/api/v2/contest-effect/$}, payload["contest-effect"])
    assert_match(%r{/api/v2/contest-type/$}, payload["contest-type"])
    assert_match(%r{/api/v2/egg-group/$}, payload["egg-group"])
    assert_match(%r{/api/v2/evolution-chain/$}, payload["evolution-chain"])
    assert_match(%r{/api/v2/evolution-trigger/$}, payload["evolution-trigger"])
    assert_match(%r{/api/v2/encounter-condition/$}, payload["encounter-condition"])
    assert_match(%r{/api/v2/encounter-condition-value/$}, payload["encounter-condition-value"])
    assert_match(%r{/api/v2/encounter-method/$}, payload["encounter-method"])
    assert_match(%r{/api/v2/gender/$}, payload["gender"])
    assert_match(%r{/api/v2/generation/$}, payload["generation"])
    assert_match(%r{/api/v2/growth-rate/$}, payload["growth-rate"])
    assert_match(%r{/api/v2/item/$}, payload["item"])
    assert_match(%r{/api/v2/item-attribute/$}, payload["item-attribute"])
    assert_match(%r{/api/v2/item-category/$}, payload["item-category"])
    assert_match(%r{/api/v2/item-fling-effect/$}, payload["item-fling-effect"])
    assert_match(%r{/api/v2/item-pocket/$}, payload["item-pocket"])
    assert_match(%r{/api/v2/language/$}, payload["language"])
    assert_match(%r{/api/v2/location/$}, payload["location"])
    assert_match(%r{/api/v2/location-area/$}, payload["location-area"])
    assert_match(%r{/api/v2/machine/$}, payload["machine"])
    assert_match(%r{/api/v2/move/$}, payload["move"])
    assert_match(%r{/api/v2/move-ailment/$}, payload["move-ailment"])
    assert_match(%r{/api/v2/move-battle-style/$}, payload["move-battle-style"])
    assert_match(%r{/api/v2/move-category/$}, payload["move-category"])
    assert_match(%r{/api/v2/move-damage-class/$}, payload["move-damage-class"])
    assert_match(%r{/api/v2/move-learn-method/$}, payload["move-learn-method"])
    assert_match(%r{/api/v2/move-target/$}, payload["move-target"])
    assert_match(%r{/api/v2/nature/$}, payload["nature"])
    assert_match(%r{/api/v2/pal-park-area/$}, payload["pal-park-area"])
    assert_match(%r{/api/v2/pokedex/$}, payload["pokedex"])
    assert_match(%r{/api/v2/pokeathlon-stat/$}, payload["pokeathlon-stat"])
    assert_match(%r{/api/v2/pokemon/$}, payload["pokemon"])
    assert_match(%r{/api/v2/pokemon-color/$}, payload["pokemon-color"])
    assert_match(%r{/api/v2/pokemon-form/$}, payload["pokemon-form"])
    assert_match(%r{/api/v2/pokemon-habitat/$}, payload["pokemon-habitat"])
    assert_match(%r{/api/v2/pokemon-shape/$}, payload["pokemon-shape"])
    assert_match(%r{/api/v2/pokemon-species/$}, payload["pokemon-species"])
    assert_match(%r{/api/v2/region/$}, payload["region"])
    assert_match(%r{/api/v2/stat/$}, payload["stat"])
    assert_match(%r{/api/v2/super-contest-effect/$}, payload["super-contest-effect"])
    assert_match(%r{/api/v2/type/$}, payload["type"])
    assert_match(%r{/api/v2/version/$}, payload["version"])
    assert_match(%r{/api/v2/version-group/$}, payload["version-group"])

    payload.each_value do |url|
      refute_match(%r{//$}, url)
    end
  end

  test "root is available with or without trailing slash" do
    get "/api/v2"
    assert_response :success

    get "/api/v2/"
    assert_response :success
  end
end
