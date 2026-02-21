# == Schema Information
#
# Table name: pokemon_color
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_pokemon_color_on_name  (name) UNIQUE
#
class PokePokemonColor < ApplicationRecord
  self.table_name = "pokemon_color"

  has_many :pokemon_species,
           class_name: "PokePokemonSpecies",
           foreign_key: :color_id,
           inverse_of: :color,
           dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
