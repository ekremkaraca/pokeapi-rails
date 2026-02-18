module Api
  module V2
    class GenerationController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeGeneration
      RESOURCE_URL_HELPER = :api_v2_generation_url

      private

      def detail_payload(generation)
        {
          abilities: resources_payload(Ability.where(generation_id: generation.id).order(:id), :api_v2_ability_url),
          id: generation.id,
          main_region: main_region_payload(generation.main_region_id),
          moves: resources_payload(PokeMove.where(generation_id: generation.id).order(:id), :api_v2_move_url),
          name: generation.name,
          names: names_payload(generation.id),
          pokemon_species: resources_payload(PokePokemonSpecies.where(generation_id: generation.id).order(:id), :api_v2_pokemon_species_url),
          types: resources_payload(PokeType.where(generation_id: generation.id).order(:id), :api_v2_type_url),
          version_groups: resources_payload(PokeVersionGroup.where(generation_id: generation.id).order(:id), :api_v2_version_group_url)
        }
      end

      def main_region_payload(region_id)
        region = PokeRegion.find_by(id: region_id)
        return nil unless region

        resource_payload(region, :api_v2_region_url)
      end

      def names_payload(generation_id)
        rows = PokeGenerationName.where(generation_id: generation_id)
        languages_by_id = records_by_id(PokeLanguage, rows.map(&:local_language_id))

        rows.filter_map do |row|
          language = languages_by_id[row.local_language_id]
          next unless language

          {
            name: row.name,
            language: resource_payload(language, :api_v2_language_url)
          }
        end
      end

      def resources_payload(records, route_helper)
        records.map { |record| resource_payload(record, route_helper) }
      end

      def resource_payload(record, route_helper)
        {
          name: record.name,
          url: "#{public_send(route_helper, record).sub(%r{/+\z}, '')}/"
        }
      end

      def records_by_id(model_class, ids)
        model_class.where(id: ids.uniq).index_by(&:id)
      end
    end
  end
end
