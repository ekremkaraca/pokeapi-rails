# == Schema Information
#
# Table name: ability_prose
#
#  id                :bigint           not null, primary key
#  effect            :text
#  short_effect      :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  ability_id        :integer          not null
#  local_language_id :integer          not null
#
# Indexes
#
#  index_ability_prose_on_ability_id_and_local_language_id  (ability_id,local_language_id) UNIQUE
#  index_ability_prose_on_local_language_id                 (local_language_id)
#
class PokeAbilityProse < ApplicationRecord
  self.table_name = "ability_prose"

  belongs_to :ability, inverse_of: :ability_proses
  belongs_to :local_language,
             class_name: "PokeLanguage",
             foreign_key: :local_language_id,
             inverse_of: :ability_proses
end
