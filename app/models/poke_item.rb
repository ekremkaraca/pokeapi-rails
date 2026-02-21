# == Schema Information
#
# Table name: item
#
#  id              :bigint           not null, primary key
#  cost            :integer
#  fling_power     :integer
#  name            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  category_id     :integer
#  fling_effect_id :integer
#
# Indexes
#
#  index_item_on_category_id      (category_id)
#  index_item_on_fling_effect_id  (fling_effect_id)
#  index_item_on_name             (name)
#
class PokeItem < ApplicationRecord
  self.table_name = "item"

  belongs_to :category,
             class_name: "PokeItemCategory",
             foreign_key: :category_id,
             inverse_of: :items,
             optional: true
  belongs_to :fling_effect,
             class_name: "PokeItemFlingEffect",
             foreign_key: :fling_effect_id,
             inverse_of: :items,
             optional: true

  has_many :item_proses,
           class_name: "PokeItemProse",
           foreign_key: :item_id,
           inverse_of: :item,
           dependent: :destroy
  has_many :item_names,
           class_name: "PokeItemName",
           foreign_key: :item_id,
           inverse_of: :item,
           dependent: :destroy
  has_many :item_flavor_texts,
           class_name: "PokeItemFlavorText",
           foreign_key: :item_id,
           inverse_of: :item,
           dependent: :destroy
  has_many :item_game_indices,
           class_name: "PokeItemGameIndex",
           foreign_key: :item_id,
           inverse_of: :item,
           dependent: :destroy
  has_many :pokemon_items,
           class_name: "PokePokemonItem",
           foreign_key: :item_id,
           inverse_of: :item,
           dependent: :destroy
  has_many :machines,
           class_name: "PokeMachine",
           foreign_key: :item_id,
           inverse_of: :item,
           dependent: :nullify
  has_many :baby_triggered_evolution_chains,
           class_name: "PokeEvolutionChain",
           foreign_key: :baby_trigger_item_id,
           inverse_of: :baby_trigger_item,
           dependent: :nullify
  has_one :berry,
          class_name: "PokeBerry",
          foreign_key: :item_id,
          inverse_of: :item,
          dependent: :nullify
  has_many :item_flag_maps,
           class_name: "PokeItemFlagMap",
           foreign_key: :item_id,
           inverse_of: :item,
           dependent: :destroy

  validates :name, presence: true
end
