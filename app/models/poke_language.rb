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

  has_many :ability_changelog_proses,
           class_name: "PokeAbilityChangelogProse",
           foreign_key: :local_language_id,
           inverse_of: :local_language,
           dependent: :restrict_with_exception
  has_many :ability_flavor_texts,
           class_name: "PokeAbilityFlavorText",
           foreign_key: :language_id,
           inverse_of: :language,
           dependent: :restrict_with_exception
  has_many :ability_names,
            class_name: "PokeAbilityName",
            foreign_key: :local_language_id,
            inverse_of: :local_language,
            dependent: :restrict_with_exception
  has_many :ability_proses,
           class_name: "PokeAbilityProse",
           foreign_key: :local_language_id,
           inverse_of: :local_language,
           dependent: :restrict_with_exception
  has_many :item_proses,
           class_name: "PokeItemProse",
           foreign_key: :local_language_id,
           inverse_of: :local_language,
           dependent: :restrict_with_exception
  has_many :item_names,
           class_name: "PokeItemName",
           foreign_key: :local_language_id,
           inverse_of: :local_language,
           dependent: :restrict_with_exception
  has_many :item_flavor_texts,
           class_name: "PokeItemFlavorText",
           foreign_key: :language_id,
           inverse_of: :language,
           dependent: :restrict_with_exception
  has_many :pokemon_species_flavor_texts,
           class_name: "PokePokemonSpeciesFlavorText",
           foreign_key: :language_id,
           inverse_of: :language,
           dependent: :restrict_with_exception
  has_many :pokemon_species_names,
           class_name: "PokePokemonSpeciesName",
           foreign_key: :local_language_id,
           inverse_of: :local_language,
           dependent: :restrict_with_exception
  has_many :pokemon_species_proses,
           class_name: "PokePokemonSpeciesProse",
           foreign_key: :local_language_id,
           inverse_of: :local_language,
           dependent: :restrict_with_exception
  has_many :generation_names,
           class_name: "PokeGenerationName",
           foreign_key: :local_language_id,
           inverse_of: :local_language,
           dependent: :restrict_with_exception
  has_many :location_names,
           class_name: "PokeLocationName",
           foreign_key: :local_language_id,
           inverse_of: :local_language,
           dependent: :restrict_with_exception
  has_many :move_names,
           class_name: "PokeMoveName",
           foreign_key: :local_language_id,
           inverse_of: :local_language,
           dependent: :restrict_with_exception
  has_many :move_flavor_texts,
           class_name: "PokeMoveFlavorText",
           foreign_key: :language_id,
           inverse_of: :language,
           dependent: :restrict_with_exception
  has_many :move_effect_changelog_proses,
           class_name: "PokeMoveEffectChangelogProse",
           foreign_key: :local_language_id,
           inverse_of: :local_language,
           dependent: :restrict_with_exception
  has_many :move_effect_proses,
           class_name: "PokeMoveEffectProse",
           foreign_key: :local_language_id,
           inverse_of: :local_language,
           dependent: :restrict_with_exception
  has_many :type_names,
           class_name: "PokeTypeName",
           foreign_key: :local_language_id,
           inverse_of: :local_language,
           dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
