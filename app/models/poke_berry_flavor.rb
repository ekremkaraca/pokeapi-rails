# == Schema Information
#
# Table name: berry_flavor
#
#  id              :bigint           not null, primary key
#  name            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  contest_type_id :integer
#
# Indexes
#
#  index_berry_flavor_on_contest_type_id  (contest_type_id)
#  index_berry_flavor_on_name             (name) UNIQUE
#
class PokeBerryFlavor < ApplicationRecord
  self.table_name = "berry_flavor"

  belongs_to :contest_type,
             class_name: "PokeContestType",
             foreign_key: :contest_type_id,
             inverse_of: :berry_flavors,
             optional: true
  has_many :natures_that_like,
           class_name: "PokeNature",
           foreign_key: :likes_flavor_id,
           inverse_of: :likes_flavor,
           dependent: :nullify
  has_many :natures_that_hate,
           class_name: "PokeNature",
           foreign_key: :hates_flavor_id,
           inverse_of: :hates_flavor,
           dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
