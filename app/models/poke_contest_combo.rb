# == Schema Information
#
# Table name: contest_combo
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  first_move_id  :integer          not null
#  second_move_id :integer          not null
#
# Indexes
#
#  index_contest_combo_on_first_move_id_and_second_move_id  (first_move_id,second_move_id) UNIQUE
#  index_contest_combo_on_second_move_id                    (second_move_id)
#
class PokeContestCombo < ApplicationRecord
  self.table_name = "contest_combo"
end
