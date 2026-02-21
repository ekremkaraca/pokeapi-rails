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

  belongs_to :move,
             class_name: "PokeMove",
             foreign_key: :move_id,
             inverse_of: :move_names,
             optional: true
  belongs_to :local_language,
             class_name: "PokeLanguage",
             foreign_key: :local_language_id,
             inverse_of: :move_names,
             optional: true
end
