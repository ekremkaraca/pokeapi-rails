require "test_helper"

class ItemRelationshipsTest < ActiveSupport::TestCase
  test "item-related associations are wired and traversable" do
    item = PokeItem.create!(name: "item-rel-#{SecureRandom.hex(4)}", cost: 100)
    category = PokeItemCategory.create!(name: "item-cat-#{SecureRandom.hex(4)}")
    fling_effect = PokeItemFlingEffect.create!(name: "item-fling-#{SecureRandom.hex(4)}")
    language = PokeLanguage.create!(name: "item-lang-#{SecureRandom.hex(4)}", official: true)
    version_group = PokeVersionGroup.create!(name: "item-vg-#{SecureRandom.hex(4)}")
    generation = PokeGeneration.create!(name: "item-gen-#{SecureRandom.hex(4)}")
    version = PokeVersion.create!(name: "item-version-#{SecureRandom.hex(4)}")
    pokemon = Pokemon.create!(name: "item-mon-#{SecureRandom.hex(4)}")
    move = PokeMove.create!(name: "item-move-#{SecureRandom.hex(4)}")
    item_attribute = PokeItemAttribute.create!(name: "item-attr-#{SecureRandom.hex(4)}")

    item.update!(category: category, fling_effect: fling_effect)

    prose = PokeItemProse.create!(item: item, local_language: language, effect: "Effect", short_effect: "Short")
    item_name = PokeItemName.create!(item: item, local_language: language, name: "Localized Item Name")
    flavor_text = PokeItemFlavorText.create!(item: item, language: language, version_group: version_group, flavor_text: "Flavor")
    game_index = PokeItemGameIndex.create!(item: item, generation: generation, game_index: 1)
    pokemon_item = PokePokemonItem.create!(item: item, pokemon: pokemon, version: version, rarity: 5)
    machine = PokeMachine.create!(item: item, move: move, version_group: version_group, machine_number: 1)
    flag_map = PokeItemFlagMap.create!(item: item, item_attribute: item_attribute)

    assert_equal category.id, item.category.id
    assert_equal fling_effect.id, item.fling_effect.id
    assert_equal [ prose.id ], item.item_proses.pluck(:id)
    assert_equal [ item_name.id ], item.item_names.pluck(:id)
    assert_equal [ flavor_text.id ], item.item_flavor_texts.pluck(:id)
    assert_equal [ game_index.id ], item.item_game_indices.pluck(:id)
    assert_equal [ pokemon_item.id ], item.pokemon_items.pluck(:id)
    assert_equal [ machine.id ], item.machines.pluck(:id)
    assert_equal [ flag_map.id ], item.item_flag_maps.pluck(:id)

    assert_equal item.id, prose.item.id
    assert_equal language.id, prose.local_language.id
    assert_equal item.id, item_name.item.id
    assert_equal language.id, item_name.local_language.id
    assert_equal item.id, flavor_text.item.id
    assert_equal language.id, flavor_text.language.id
    assert_equal version_group.id, flavor_text.version_group.id
  end
end
