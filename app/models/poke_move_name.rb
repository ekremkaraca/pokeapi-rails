# == Schema Information
#
# Table name: move_name
#
#  id                :bigint           not null, primary key
#  name              :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  local_language_id :integer          not null
#  move_id           :integer          not null
#
# Indexes
#
#  index_move_name_on_local_language_id              (local_language_id)
#  index_move_name_on_move_id_and_local_language_id  (move_id,local_language_id) UNIQUE
#
class PokeMoveName < ApplicationRecord
  self.table_name = "move_name"
end
