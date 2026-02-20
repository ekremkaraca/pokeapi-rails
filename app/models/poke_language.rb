# == Schema Information
#
# Table name: language
#
#  id         :bigint           not null, primary key
#  iso3166    :string
#  iso639     :string
#  name       :string           not null
#  official   :boolean          default(FALSE), not null
#  sort_order :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_language_on_iso3166     (iso3166)
#  index_language_on_iso639      (iso639)
#  index_language_on_name        (name) UNIQUE
#  index_language_on_official    (official)
#  index_language_on_sort_order  (sort_order)
#
class PokeLanguage < ApplicationRecord
  self.table_name = "language"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
