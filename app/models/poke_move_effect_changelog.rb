# == Schema Information
#
# Table name: move_effect_changelog
#
#  id                          :bigint           not null, primary key
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  changed_in_version_group_id :integer          not null
#  effect_id                   :integer          not null
#
# Indexes
#
#  index_move_effect_changelog_on_changed_in_version_group_id  (changed_in_version_group_id)
#  index_move_effect_changelog_on_effect_id                    (effect_id)
#
class PokeMoveEffectChangelog < ApplicationRecord
  self.table_name = "move_effect_changelog"
end
