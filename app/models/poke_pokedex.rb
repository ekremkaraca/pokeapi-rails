# == Schema Information
#
# Table name: pokedex
#
#  id             :bigint           not null, primary key
#  is_main_series :boolean          default(TRUE), not null
#  name           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  region_id      :integer
#
# Indexes
#
#  index_pokedex_on_is_main_series  (is_main_series)
#  index_pokedex_on_name            (name) UNIQUE
#  index_pokedex_on_region_id       (region_id)
#
class PokePokedex < ApplicationRecord
  self.table_name = "pokedex"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
