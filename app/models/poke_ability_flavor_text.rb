# == Schema Information
#
# Table name: ability_flavor_text
#
#  id               :bigint           not null, primary key
#  flavor_text      :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  ability_id       :integer          not null
#  language_id      :integer          not null
#  version_group_id :integer          not null
#
# Indexes
#
#  idx_ability_flavor_text_lookup                 (ability_id,version_group_id,language_id)
#  index_ability_flavor_text_on_ability_id        (ability_id)
#  index_ability_flavor_text_on_language_id       (language_id)
#  index_ability_flavor_text_on_version_group_id  (version_group_id)
#
class PokeAbilityFlavorText < ApplicationRecord
  self.table_name = "ability_flavor_text"

  belongs_to :ability,
             class_name: "Ability",
             foreign_key: :ability_id,
             inverse_of: :flavor_texts
  belongs_to :version_group,
             class_name: "PokeVersionGroup",
             foreign_key: :version_group_id,
             inverse_of: :ability_flavor_texts
  belongs_to :language,
             class_name: "PokeLanguage",
             foreign_key: :language_id,
             inverse_of: :ability_flavor_texts
end
