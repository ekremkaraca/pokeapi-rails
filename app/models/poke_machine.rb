# == Schema Information
#
# Table name: machine
#
#  id               :bigint           not null, primary key
#  machine_number   :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  item_id          :integer
#  move_id          :integer
#  version_group_id :integer
#
# Indexes
#
#  index_machine_on_item_id                              (item_id)
#  index_machine_on_machine_number                       (machine_number)
#  index_machine_on_machine_number_and_version_group_id  (machine_number,version_group_id) UNIQUE
#  index_machine_on_move_id                              (move_id)
#  index_machine_on_version_group_id                     (version_group_id)
#
class PokeMachine < ApplicationRecord
  self.table_name = "machine"

  belongs_to :item,
             class_name: "PokeItem",
             foreign_key: :item_id,
             inverse_of: :machines,
             optional: true
  belongs_to :move,
             class_name: "PokeMove",
             foreign_key: :move_id,
             inverse_of: :machines,
             optional: true
  belongs_to :version_group,
             class_name: "PokeVersionGroup",
             foreign_key: :version_group_id,
             inverse_of: :machines,
             optional: true
end
