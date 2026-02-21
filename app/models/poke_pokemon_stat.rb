# == Schema Information
#
# Table name: pokemon_stat
#
#  id         :bigint           not null, primary key
#  base_stat  :integer          not null
#  effort     :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  pokemon_id :integer          not null
#  stat_id    :integer          not null
#
# Indexes
#
#  index_pokemon_stat_on_pokemon_id_and_stat_id  (pokemon_id,stat_id) UNIQUE
#  index_pokemon_stat_on_stat_id                 (stat_id)
#
class PokePokemonStat < ApplicationRecord
  self.table_name = "pokemon_stat"

  belongs_to :pokemon,
             class_name: "Pokemon",
             foreign_key: :pokemon_id,
             inverse_of: :pokemon_stats
  belongs_to :stat,
             class_name: "PokeStat",
             foreign_key: :stat_id,
             inverse_of: :pokemon_stats
end
