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
end
