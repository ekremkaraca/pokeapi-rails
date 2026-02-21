# == Schema Information
#
# Table name: move_learn_method
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_move_learn_method_on_name  (name) UNIQUE
#
class PokeMoveLearnMethod < ApplicationRecord
  self.table_name = "move_learn_method"

  has_many :pokemon_moves,
           class_name: "PokePokemonMove",
           foreign_key: :pokemon_move_method_id,
           inverse_of: :move_learn_method,
           dependent: :restrict_with_exception
  has_many :version_group_pokemon_move_methods,
           class_name: "PokeVersionGroupPokemonMoveMethod",
           foreign_key: :pokemon_move_method_id,
           inverse_of: :move_learn_method,
           dependent: :restrict_with_exception
  has_many :version_groups,
           through: :version_group_pokemon_move_methods,
           source: :version_group

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
