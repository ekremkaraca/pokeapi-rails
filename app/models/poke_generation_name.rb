# == Schema Information
#
# Table name: generation_name
#
#  id                :bigint           not null, primary key
#  name              :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  generation_id     :integer          not null
#  local_language_id :integer          not null
#
# Indexes
#
#  index_generation_name_on_generation_id_and_local_language_id  (generation_id,local_language_id) UNIQUE
#  index_generation_name_on_local_language_id                    (local_language_id)
#
class PokeGenerationName < ApplicationRecord
  self.table_name = "generation_name"

  belongs_to :generation,
             class_name: "PokeGeneration",
             foreign_key: :generation_id,
             inverse_of: :generation_names,
             optional: true
  belongs_to :local_language,
             class_name: "PokeLanguage",
             foreign_key: :local_language_id,
             inverse_of: :generation_names,
             optional: true
end
