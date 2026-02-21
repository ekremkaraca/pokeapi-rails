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

  belongs_to :move_effect_changelog,
             class_name: "PokeMoveEffectChangelog",
             foreign_key: :move_effect_changelog_id,
             inverse_of: :proses,
             optional: true
  belongs_to :local_language,
             class_name: "PokeLanguage",
             foreign_key: :local_language_id,
             inverse_of: :move_effect_changelog_proses,
             optional: true
end
