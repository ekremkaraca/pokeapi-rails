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
end
