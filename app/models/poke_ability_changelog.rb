# == Schema Information
#
# Table name: ability_changelog
#
#  id                          :bigint           not null, primary key
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  ability_id                  :integer          not null
#  changed_in_version_group_id :integer          not null
#
# Indexes
#
#  index_ability_changelog_on_ability_id                   (ability_id)
#  index_ability_changelog_on_changed_in_version_group_id  (changed_in_version_group_id)
#
class PokeAbilityChangelog < ApplicationRecord
  self.table_name = "ability_changelog"

  has_many :ability_changelog_proses,
           class_name: "PokeAbilityChangelogProse",
           foreign_key: :ability_changelog_id,
           inverse_of: :ability_changelog,
           dependent: :destroy
  belongs_to :ability, inverse_of: :changelogs
  belongs_to :changed_in_version_group,
             class_name: "PokeVersionGroup",
             foreign_key: :changed_in_version_group_id,
             inverse_of: :ability_changelogs
end
