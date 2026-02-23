require "test_helper"
require "securerandom"

class Api::V2::MoveControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeMove.delete_all

    [
      { name: "pound", generation_id: 1, type_id: 1, power: 40, pp: 35, accuracy: 100, priority: 0, target_id: 10, damage_class_id: 2, effect_id: 1, effect_chance: nil, contest_type_id: 5, contest_effect_id: 1, super_contest_effect_id: 5 },
      { name: "karate-chop", generation_id: 1, type_id: 2, power: 50, pp: 25, accuracy: 100, priority: 0, target_id: 10, damage_class_id: 2, effect_id: 2, effect_chance: nil, contest_type_id: 5, contest_effect_id: 2, super_contest_effect_id: 6 },
      { name: "double-slap", generation_id: 1, type_id: 1, power: 15, pp: 10, accuracy: 85, priority: 0, target_id: 10, damage_class_id: 2, effect_id: 3, effect_chance: nil, contest_type_id: 5, contest_effect_id: 3, super_contest_effect_id: 5 }
    ].each do |attrs|
      PokeMove.create!(attrs)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/move", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 3, payload["count"]
    assert_equal 2, payload["results"].length
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/move/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/move", params: { q: "slap" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 1, payload["count"]
    assert_equal [ "double-slap" ], payload["results"].map { |r| r["name"] }
  end

  test "show supports retrieval by id and name" do
    move = PokeMove.find_by!(name: "pound")

    get "/api/v2/move/#{move.id}"
    assert_response :success
    assert_observability_headers
    payload = JSON.parse(response.body)
    assert_equal %w[accuracy contest_combos contest_effect contest_type damage_class effect_chance effect_changes effect_entries flavor_text_entries generation id learned_by_pokemon machines meta name names past_values power pp priority stat_changes super_contest_effect target type], payload.keys.sort
    assert_equal "pound", payload["name"]
    assert_equal 40, payload["power"]
    assert_equal 100, payload["accuracy"]
    assert_equal 35, payload["pp"]
    assert_equal 0, payload["priority"]
    assert_equal [], payload["learned_by_pokemon"]
    assert_equal [], payload["machines"]
    assert_equal [], payload["names"]
    assert_equal [], payload["past_values"]
    assert_equal [], payload["stat_changes"]
    assert_equal [], payload["flavor_text_entries"]
    assert_equal %w[use_after use_before], payload["contest_combos"]["normal"].keys.sort
    assert_equal %w[use_after use_before], payload["contest_combos"]["super"].keys.sort

    get "/api/v2/move/POUND"
    assert_response :success
    assert_observability_headers
  end

  test "show query count stays within budget" do
    query_count = capture_select_query_count do
      get "/api/v2/move/pound"
      assert_response :success
    end

    assert_operator query_count, :<=, 22
  end

  test "list supports conditional get with etag" do
    get "/api/v2/move", params: { limit: 2, offset: 0, q: "p" }
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/move", params: { limit: 2, offset: 0, q: "p" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    move = PokeMove.find_by!(name: "pound")

    get "/api/v2/move/#{move.id}"
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/move/#{move.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show reuses language and version-group lookups across nested payload sections" do
    move = PokeMove.find_by!(name: "pound")
    suffix = SecureRandom.hex(6)
    language = PokeLanguage.create!(name: "language-#{suffix}")
    version_group = PokeVersionGroup.create!(name: "version-group-#{suffix}")
    generation = PokeGeneration.create!(name: "generation-#{suffix}")
    type = PokeType.create!(name: "type-#{suffix}")
    target = PokeMoveTarget.create!(name: "target-#{suffix}")
    damage_class = PokeMoveDamageClass.create!(name: "damage-class-#{suffix}")
    contest_type = PokeContestType.create!(name: "contest-type-#{suffix}")
    contest_effect = PokeContestEffect.create!(appeal: 1, jam: 0)
    super_contest_effect = PokeSuperContestEffect.create!(appeal: 1)
    stat = PokeStat.create!(name: "stat-#{suffix}")

    move.update!(
      generation_id: generation.id,
      type_id: type.id,
      target_id: target.id,
      damage_class_id: damage_class.id,
      contest_type_id: contest_type.id,
      contest_effect_id: contest_effect.id,
      super_contest_effect_id: super_contest_effect.id
    )

    PokeMoveName.create!(move_id: move.id, local_language_id: language.id, name: "Pound")
    PokeMoveFlavorText.create!(move_id: move.id, version_group_id: version_group.id, language_id: language.id, flavor_text: "A basic attack.")
    PokeMoveEffectProse.create!(move_effect_id: move.effect_id, local_language_id: language.id, short_effect: "Deals damage.", effect: "Deals damage.")
    changelog = PokeMoveEffectChangelog.create!(effect_id: move.effect_id, changed_in_version_group_id: version_group.id)
    PokeMoveEffectChangelogProse.create!(move_effect_changelog_id: changelog.id, local_language_id: language.id, effect: "Updated effect text.")
    PokeMachine.create!(move_id: move.id, version_group_id: version_group.id, machine_number: 1)
    PokeMoveChangelog.create!(move_id: move.id, changed_in_version_group_id: version_group.id, type_id: type.id)
    PokeMoveMetaStatChange.create!(move_id: move.id, stat_id: stat.id, change: 1)

    queries = capture_select_queries do
      get "/api/v2/move/#{move.id}"
      assert_response :success
    end

    language_queries = queries.count { |sql| sql.include?('FROM "language"') }
    version_group_queries = queries.count { |sql| sql.include?('FROM "version_group"') }

    assert_operator language_queries, :<=, 2
    assert_operator version_group_queries, :<=, 2
  end

  test "show resolves move meta ailment and category when id is zero" do
    move = PokeMove.find_by!(name: "pound")
    suffix = SecureRandom.hex(6)
    ailment = PokeMoveAilment.create!(id: 0, name: "ailment-#{suffix}")
    category = PokeMoveMetaCategory.create!(id: 0, name: "category-#{suffix}")
    PokeMoveMeta.create!(move_id: move.id, meta_ailment_id: ailment.id, meta_category_id: category.id)

    get "/api/v2/move/#{move.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal "ailment-#{suffix}", payload.dig("meta", "ailment", "name")
    assert_equal "category-#{suffix}", payload.dig("meta", "category", "name")
  end
end
