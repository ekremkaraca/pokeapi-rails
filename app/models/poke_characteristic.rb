# == Schema Information
#
# Table name: characteristic
#
#  id         :bigint           not null, primary key
#  gene_mod_5 :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  stat_id    :integer
#
# Indexes
#
#  index_characteristic_on_gene_mod_5  (gene_mod_5)
#  index_characteristic_on_stat_id     (stat_id)
#
class PokeCharacteristic < ApplicationRecord
  self.table_name = "characteristic"

  belongs_to :stat,
             class_name: "PokeStat",
             foreign_key: :stat_id,
             inverse_of: :characteristics,
             optional: true
end
