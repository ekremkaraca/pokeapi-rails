# == Schema Information
#
# Table name: move_meta_category
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_move_meta_category_on_name  (name) UNIQUE
#
class PokeMoveMetaCategory < ApplicationRecord
  self.table_name = "move_meta_category"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
