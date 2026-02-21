# == Schema Information
#
# Table name: move_effect_prose
#
#  id                :bigint           not null, primary key
#  effect            :text
#  short_effect      :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  local_language_id :integer          not null
#  move_effect_id    :integer          not null
#
# Indexes
#
#  idx_on_move_effect_id_local_language_id_a16f74b628  (move_effect_id,local_language_id) UNIQUE
#  index_move_effect_prose_on_local_language_id        (local_language_id)
#
class PokeMoveEffectProse < ApplicationRecord
  self.table_name = "move_effect_prose"

  belongs_to :local_language,
             class_name: "PokeLanguage",
             foreign_key: :local_language_id,
             inverse_of: :move_effect_proses,
             optional: true
end
