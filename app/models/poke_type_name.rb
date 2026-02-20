# == Schema Information
#
# Table name: type_name
#
#  id                :bigint           not null, primary key
#  name              :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  local_language_id :integer          not null
#  type_id           :integer          not null
#
# Indexes
#
#  index_type_name_on_local_language_id              (local_language_id)
#  index_type_name_on_type_id_and_local_language_id  (type_id,local_language_id) UNIQUE
#
class PokeTypeName < ApplicationRecord
  self.table_name = "type_name"
end
