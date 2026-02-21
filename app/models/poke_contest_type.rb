# == Schema Information
#
# Table name: contest_type
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_contest_type_on_name  (name) UNIQUE
#
class PokeContestType < ApplicationRecord
  self.table_name = "contest_type"

  has_many :berry_flavors,
           class_name: "PokeBerryFlavor",
           foreign_key: :contest_type_id,
           inverse_of: :contest_type,
           dependent: :nullify
  has_many :moves,
           class_name: "PokeMove",
           foreign_key: :contest_type_id,
           inverse_of: :contest_type,
           dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
