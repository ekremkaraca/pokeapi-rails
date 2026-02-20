# == Schema Information
#
# Table name: berry
#
#  id                   :bigint           not null, primary key
#  growth_time          :integer
#  max_harvest          :integer
#  name                 :string           not null
#  natural_gift_power   :integer
#  size                 :integer
#  smoothness           :integer
#  soil_dryness         :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  berry_firmness_id    :integer
#  item_id              :integer
#  natural_gift_type_id :integer
#
# Indexes
#
#  index_berry_on_berry_firmness_id     (berry_firmness_id)
#  index_berry_on_item_id               (item_id)
#  index_berry_on_name                  (name) UNIQUE
#  index_berry_on_natural_gift_type_id  (natural_gift_type_id)
#
class PokeBerry < ApplicationRecord
  self.table_name = "berry"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
