# == Schema Information
#
# Table name: version
#
#  id               :bigint           not null, primary key
#  name             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  version_group_id :integer
#
# Indexes
#
#  index_version_on_name              (name) UNIQUE
#  index_version_on_version_group_id  (version_group_id)
#
class PokeVersion < ApplicationRecord
  self.table_name = "version"

  belongs_to :version_group,
             class_name: "PokeVersionGroup",
             foreign_key: :version_group_id,
             inverse_of: :versions,
             optional: true

  has_many :pokemon_game_indices,
           class_name: "PokePokemonGameIndex",
           foreign_key: :version_id,
           inverse_of: :version,
           dependent: :restrict_with_exception
  has_many :pokemon_species_flavor_texts,
           class_name: "PokePokemonSpeciesFlavorText",
           foreign_key: :version_id,
           inverse_of: :version,
           dependent: :restrict_with_exception
  has_many :encounters,
           class_name: "PokeEncounter",
           foreign_key: :version_id,
           inverse_of: :version,
           dependent: :restrict_with_exception
  has_many :pokemon_items,
           class_name: "PokePokemonItem",
           foreign_key: :version_id,
           inverse_of: :version,
           dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
