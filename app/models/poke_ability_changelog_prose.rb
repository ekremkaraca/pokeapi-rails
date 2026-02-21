# == Schema Information
#
# Table name: ability_changelog_prose
#
#  id                   :bigint           not null, primary key
#  effect               :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  ability_changelog_id :integer          not null
#  local_language_id    :integer          not null
#
# Indexes
#
#  idx_ability_changelog_prose_unique                  (ability_changelog_id,local_language_id) UNIQUE
#  index_ability_changelog_prose_on_local_language_id  (local_language_id)
#
class PokeAbilityChangelogProse < ApplicationRecord
  self.table_name = "ability_changelog_prose"

  belongs_to :ability_changelog,
             class_name: "PokeAbilityChangelog",
             foreign_key: :ability_changelog_id,
             inverse_of: :ability_changelog_proses

  belongs_to :local_language,
             class_name: "PokeLanguage",
             foreign_key: :local_language_id,
             inverse_of: :ability_changelog_proses
end
