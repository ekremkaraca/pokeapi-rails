# == Schema Information
#
# Table name: super_contest_combo
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  first_move_id  :integer          not null
#  second_move_id :integer          not null
#
# Indexes
#
#  index_super_contest_combo_on_first_move_id_and_second_move_id  (first_move_id,second_move_id) UNIQUE
#  index_super_contest_combo_on_second_move_id                    (second_move_id)
#
class PokeSuperContestCombo < ApplicationRecord
  self.table_name = "super_contest_combo"

  belongs_to :first_move,
             class_name: "PokeMove",
             foreign_key: :first_move_id,
             inverse_of: :super_contest_combos_as_first,
             optional: true
  belongs_to :second_move,
             class_name: "PokeMove",
             foreign_key: :second_move_id,
             inverse_of: :super_contest_combos_as_second,
             optional: true
end
