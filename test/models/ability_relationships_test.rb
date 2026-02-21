require "test_helper"

class AbilityRelationshipsTest < ActiveSupport::TestCase
  test "ability-related associations are wired and traversable" do
    ability = Ability.create!(name: "ability-rel-#{SecureRandom.hex(4)}", is_main_series: true)
    version_group = PokeVersionGroup.create!(name: "ability-vg-#{SecureRandom.hex(4)}")
    language = PokeLanguage.create!(name: "ability-lang-#{SecureRandom.hex(4)}", official: true)

    changelog = PokeAbilityChangelog.create!(ability: ability, changed_in_version_group_id: version_group.id)
    changelog_prose = PokeAbilityChangelogProse.create!(
      ability_changelog: changelog,
      local_language: language,
      effect: "Updated ability effect"
    )

    flavor_text = PokeAbilityFlavorText.create!(
      ability: ability,
      version_group: version_group,
      language: language,
      flavor_text: "Flavor text"
    )

    ability_name = PokeAbilityName.create!(
      ability: ability,
      local_language: language,
      name: "Localized Name"
    )

    ability_prose = PokeAbilityProse.create!(
      ability: ability,
      local_language: language,
      effect: "Effect",
      short_effect: "Short"
    )

    assert_equal [ changelog.id ], ability.changelogs.pluck(:id)
    assert_equal version_group.id, changelog.changed_in_version_group.id
    assert_equal [ changelog_prose.id ], changelog.ability_changelog_proses.pluck(:id)
    assert_equal changelog.id, changelog_prose.ability_changelog.id
    assert_equal [ flavor_text.id ], ability.flavor_texts.pluck(:id)
    assert_equal [ ability_name.id ], ability.ability_names.pluck(:id)
    assert_equal [ ability_prose.id ], ability.ability_proses.pluck(:id)
    assert_equal [ changelog_prose.id ], language.ability_changelog_proses.pluck(:id)
    assert_equal [ ability_name.id ], language.ability_names.pluck(:id)
    assert_equal [ ability_prose.id ], language.ability_proses.pluck(:id)
    assert_equal [ flavor_text.id ], language.ability_flavor_texts.pluck(:id)
  end
end
