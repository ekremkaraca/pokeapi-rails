# == Schema Information
#
# Table name: move_effect_changelog_prose
#
#  id                       :bigint           not null, primary key
#  effect                   :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  local_language_id        :integer          not null
#  move_effect_changelog_id :integer          not null
#
# Indexes
#
#  idx_move_effect_changelog_prose_unique                  (move_effect_changelog_id,local_language_id) UNIQUE
#  index_move_effect_changelog_prose_on_local_language_id  (local_language_id)
#
class PokeMoveEffectChangelogProse < ApplicationRecord
  self.table_name = "move_effect_changelog_prose"
end
