# == Schema Information
#
# Table name: pokedex_version_group
#
#  id               :bigint           not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  pokedex_id       :integer          not null
#  version_group_id :integer          not null
#
# Indexes
#
#  index_pokedex_version_group_on_pokedex_id_and_version_group_id  (pokedex_id,version_group_id) UNIQUE
#  index_pokedex_version_group_on_version_group_id                 (version_group_id)
#
class PokePokedexVersionGroup < ApplicationRecord
  self.table_name = "pokedex_version_group"

  belongs_to :pokedex,
             class_name: "PokePokedex",
             foreign_key: :pokedex_id,
             inverse_of: :pokedex_version_groups,
             optional: true
  belongs_to :version_group,
             class_name: "PokeVersionGroup",
             foreign_key: :version_group_id,
             inverse_of: :pokedex_version_groups,
             optional: true
end
