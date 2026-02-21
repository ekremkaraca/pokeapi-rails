# == Schema Information
#
# Table name: location_name
#
#  id                :bigint           not null, primary key
#  name              :string
#  subtitle          :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  local_language_id :integer          not null
#  location_id       :integer          not null
#
# Indexes
#
#  index_location_name_on_local_language_id                  (local_language_id)
#  index_location_name_on_location_id_and_local_language_id  (location_id,local_language_id) UNIQUE
#
class PokeLocationName < ApplicationRecord
  self.table_name = "location_name"

  belongs_to :location,
             class_name: "PokeLocation",
             foreign_key: :location_id,
             inverse_of: :location_names,
             optional: true
  belongs_to :local_language,
             class_name: "PokeLanguage",
             foreign_key: :local_language_id,
             inverse_of: :location_names,
             optional: true
end
