# == Schema Information
#
# Table name: pokemon_stat_past
#
#  id            :bigint           not null, primary key
#  base_stat     :integer          not null
#  effort        :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  generation_id :integer          not null
#  pokemon_id    :integer          not null
#  stat_id       :integer          not null
#
# Indexes
#
#  idx_pokemon_stat_past_on_pokemon_generation_stat  (pokemon_id,generation_id,stat_id) UNIQUE
#  index_pokemon_stat_past_on_generation_id          (generation_id)
#  index_pokemon_stat_past_on_stat_id                (stat_id)
#
class PokePokemonStatPast < ApplicationRecord
  self.table_name = "pokemon_stat_past"

  belongs_to :pokemon,
             class_name: "Pokemon",
             foreign_key: :pokemon_id,
             inverse_of: :pokemon_stat_pasts
  belongs_to :generation,
             class_name: "PokeGeneration",
             foreign_key: :generation_id,
             inverse_of: :pokemon_stat_pasts
  belongs_to :stat,
             class_name: "PokeStat",
             foreign_key: :stat_id,
             inverse_of: :pokemon_stat_pasts
end
