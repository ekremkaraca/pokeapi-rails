require "test_helper"

class PokeAbilityChangelogAssociationTest < ActiveSupport::TestCase
  test "ability_changelog_proses uses ability_changelog_id foreign key" do
    ability = Ability.create!(name: "assoc-ability-#{SecureRandom.hex(4)}", is_main_series: true)
    version_group = PokeVersionGroup.create!(name: "assoc-vg-#{SecureRandom.hex(4)}")
    language = PokeLanguage.create!(name: "assoc-lang-#{SecureRandom.hex(4)}", official: true)

    changelog = PokeAbilityChangelog.create!(
      ability_id: ability.id,
      changed_in_version_group_id: version_group.id
    )

    prose = PokeAbilityChangelogProse.create!(
      ability_changelog_id: changelog.id,
      local_language_id: language.id,
      effect: "Updated effect text"
    )

    assert_equal [ prose.id ], changelog.ability_changelog_proses.pluck(:id)
    assert_equal changelog.id, prose.ability_changelog.id
    assert_equal language.id, prose.local_language.id
    assert_equal [ prose.id ], language.ability_changelog_proses.pluck(:id)
  end
end
