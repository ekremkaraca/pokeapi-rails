# == Schema Information
#
# Table name: move_target
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_move_target_on_name  (name) UNIQUE
#
class PokeMoveTarget < ApplicationRecord
  self.table_name = "move_target"

  has_many :moves,
           class_name: "PokeMove",
           foreign_key: :target_id,
           inverse_of: :target,
           dependent: :nullify
  has_many :move_changelogs,
           class_name: "PokeMoveChangelog",
           foreign_key: :target_id,
           inverse_of: :target,
           dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
