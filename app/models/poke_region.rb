# == Schema Information
#
# Table name: region
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_region_on_name  (name) UNIQUE
#
class PokeRegion < ApplicationRecord
  self.table_name = "region"

  has_many :locations,
           class_name: "PokeLocation",
           foreign_key: :region_id,
           inverse_of: :region,
           dependent: :nullify
  has_many :pokedexes,
           class_name: "PokePokedex",
           foreign_key: :region_id,
           inverse_of: :region,
           dependent: :nullify
  has_many :main_generations,
           class_name: "PokeGeneration",
           foreign_key: :main_region_id,
           inverse_of: :main_region,
           dependent: :nullify
  has_many :version_group_regions,
           class_name: "PokeVersionGroupRegion",
           foreign_key: :region_id,
           inverse_of: :region,
           dependent: :restrict_with_exception
  has_many :version_groups,
           through: :version_group_regions,
           source: :version_group

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
