# == Schema Information
#
# Table name: nature
#
#  id                :bigint           not null, primary key
#  game_index        :integer
#  name              :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  decreased_stat_id :integer
#  hates_flavor_id   :integer
#  increased_stat_id :integer
#  likes_flavor_id   :integer
#
# Indexes
#
#  index_nature_on_decreased_stat_id  (decreased_stat_id)
#  index_nature_on_game_index         (game_index)
#  index_nature_on_hates_flavor_id    (hates_flavor_id)
#  index_nature_on_increased_stat_id  (increased_stat_id)
#  index_nature_on_likes_flavor_id    (likes_flavor_id)
#  index_nature_on_name               (name) UNIQUE
#
class PokeNature < ApplicationRecord
  self.table_name = "nature"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
