module Api
  module V2
    class GenerationController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeGeneration
      RESOURCE_URL_HELPER = :api_v2_generation_url

      private

      def detail_payload(generation)
        {
          abilities: resources_payload(generation.abilities.order(:id), :api_v2_ability_url),
          id: generation.id,
          main_region: main_region_payload(generation),
          moves: resources_payload(generation.moves.order(:id), :api_v2_move_url),
          name: generation.name,
          names: names_payload(generation),
          pokemon_species: resources_payload(generation.pokemon_species.order(:id), :api_v2_pokemon_species_url),
          types: resources_payload(generation.types.order(:id), :api_v2_type_url),
          version_groups: resources_payload(generation.version_groups.order(:id), :api_v2_version_group_url)
        }
      end

      def main_region_payload(generation)
        region = generation.main_region
        return nil unless region

        resource_payload(region, :api_v2_region_url)
      end

      def names_payload(generation)
        rows = generation.generation_names.includes(:local_language)

        rows.filter_map do |row|
          language = row.local_language
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
    end
  end
end
