# == Schema Information
#
# Table name: move_changelog
#
#  id                          :bigint           not null, primary key
#  accuracy                    :integer
#  effect_chance               :integer
#  power                       :integer
#  pp                          :integer
#  priority                    :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  changed_in_version_group_id :integer          not null
#  effect_id                   :integer
#  move_id                     :integer          not null
#  target_id                   :integer
#  type_id                     :integer
#
# Indexes
#
#  idx_move_changelog_unique                            (move_id,changed_in_version_group_id) UNIQUE
#  index_move_changelog_on_changed_in_version_group_id  (changed_in_version_group_id)
#  index_move_changelog_on_type_id                      (type_id)
#
class PokeMoveChangelog < ApplicationRecord
  self.table_name = "move_changelog"

  belongs_to :move,
             class_name: "PokeMove",
             foreign_key: :move_id,
             inverse_of: :move_changelogs,
             optional: true
  belongs_to :changed_in_version_group,
             class_name: "PokeVersionGroup",
             foreign_key: :changed_in_version_group_id,
             inverse_of: :move_changelogs,
             optional: true
  belongs_to :target,
             class_name: "PokeMoveTarget",
             foreign_key: :target_id,
             inverse_of: :move_changelogs,
             optional: true
  belongs_to :type,
             class_name: "PokeType",
             foreign_key: :type_id,
             inverse_of: :move_changelogs,
             optional: true
end
