# == Schema Information
#
# Table name: ability
#
#  id             :bigint           not null, primary key
#  is_main_series :boolean          default(TRUE), not null
#  name           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  generation_id  :integer
#
# Indexes
#
#  index_ability_on_generation_id   (generation_id)
#  index_ability_on_is_main_series  (is_main_series)
#  index_ability_on_name            (name) UNIQUE
#
class Ability < ApplicationRecord
  self.table_name = "ability"

  belongs_to :generation,
             class_name: "PokeGeneration",
             foreign_key: :generation_id,
             inverse_of: :abilities,
             optional: true

  has_many :pokemon_abilities, class_name: "PokePokemonAbility"
  has_many :changelogs,
           class_name: "PokeAbilityChangelog",
           foreign_key: :ability_id,
           inverse_of: :ability,
           dependent: :destroy
  has_many :flavor_texts,
           class_name: "PokeAbilityFlavorText",
           foreign_key: :ability_id,
           inverse_of: :ability,
           dependent: :destroy

  has_many :ability_names,
            class_name: "PokeAbilityName",
            foreign_key: :ability_id,
            inverse_of: :ability,
            dependent: :destroy

  has_many :ability_proses,
            class_name: "PokeAbilityProse",
            foreign_key: :ability_id,
            inverse_of: :ability,
            dependent: :destroy

  has_many :pokemon, through: :pokemon_abilities

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
