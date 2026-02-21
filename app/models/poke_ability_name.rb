# == Schema Information
#
# Table name: ability_name
#
#  id                :bigint           not null, primary key
#  name              :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  ability_id        :integer          not null
#  local_language_id :integer          not null
#
# Indexes
#
#  idx_ability_name_lookup                  (ability_id,local_language_id)
#  index_ability_name_on_ability_id         (ability_id)
#  index_ability_name_on_local_language_id  (local_language_id)
#
class PokeAbilityName < ApplicationRecord
  self.table_name = "ability_name"

  belongs_to :ability, inverse_of: :ability_names

  belongs_to :local_language,
              class_name: "PokeLanguage",
              foreign_key: :local_language_id,
              inverse_of: :ability_names
end
