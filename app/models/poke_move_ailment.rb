# == Schema Information
#
# Table name: move_ailment
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_move_ailment_on_name  (name) UNIQUE
#
class PokeMoveAilment < ApplicationRecord
  self.table_name = "move_ailment"

  has_many :move_metas,
           class_name: "PokeMoveMeta",
           foreign_key: :meta_ailment_id,
           inverse_of: :meta_ailment,
           dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
