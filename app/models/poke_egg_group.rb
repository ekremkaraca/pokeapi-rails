# == Schema Information
#
# Table name: egg_group
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_egg_group_on_name  (name) UNIQUE
#
class PokeEggGroup < ApplicationRecord
  self.table_name = "egg_group"

  has_many :pokemon_egg_groups,
           class_name: "PokePokemonEggGroup",
           foreign_key: :egg_group_id,
           inverse_of: :egg_group,
           dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
