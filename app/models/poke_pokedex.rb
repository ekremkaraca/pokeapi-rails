# == Schema Information
#
# Table name: pokedex
#
#  id             :bigint           not null, primary key
#  is_main_series :boolean          default(TRUE), not null
#  name           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  region_id      :integer
#
# Indexes
#
#  index_pokedex_on_is_main_series  (is_main_series)
#  index_pokedex_on_name            (name) UNIQUE
#  index_pokedex_on_region_id       (region_id)
#
class PokePokedex < ApplicationRecord
  self.table_name = "pokedex"

  belongs_to :region,
             class_name: "PokeRegion",
             foreign_key: :region_id,
             inverse_of: :pokedexes,
             optional: true

  has_many :pokemon_dex_numbers,
           class_name: "PokePokemonDexNumber",
           foreign_key: :pokedex_id,
           inverse_of: :pokedex,
           dependent: :restrict_with_exception
  has_many :pokedex_version_groups,
           class_name: "PokePokedexVersionGroup",
           foreign_key: :pokedex_id,
           inverse_of: :pokedex,
           dependent: :restrict_with_exception
  has_many :version_groups,
           through: :pokedex_version_groups,
           source: :version_group

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
