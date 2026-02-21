require "test_helper"

class PokeAbilityFlavorTextAssociationTest < ActiveSupport::TestCase
  test "belongs to ability, version_group, and language" do
    ability = Ability.create!(name: "flavor-ability-#{SecureRandom.hex(4)}", is_main_series: true)
    version_group = PokeVersionGroup.create!(name: "flavor-vg-#{SecureRandom.hex(4)}")
    language = PokeLanguage.create!(name: "flavor-lang-#{SecureRandom.hex(4)}", official: true)

    flavor_text = PokeAbilityFlavorText.create!(
      ability_id: ability.id,
      version_group_id: version_group.id,
      language_id: language.id,
      flavor_text: "Flavor text sample"
    )

    assert_equal ability.id, flavor_text.ability.id
    assert_equal version_group.id, flavor_text.version_group.id
    assert_equal language.id, flavor_text.language.id
    assert_equal [ flavor_text.id ], ability.flavor_texts.pluck(:id)
    assert_equal [ flavor_text.id ], version_group.ability_flavor_texts.pluck(:id)
    assert_equal [ flavor_text.id ], language.ability_flavor_texts.pluck(:id)
  end
end
