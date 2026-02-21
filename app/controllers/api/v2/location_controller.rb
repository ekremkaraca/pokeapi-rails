module Api
  module V2
    class LocationController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeLocation
      RESOURCE_URL_HELPER = :api_v2_location_url

      private

      def detail_payload(location)
        {
          areas: areas_payload(location),
          game_indices: game_indices_payload(location),
          id: location.id,
          name: location.name,
          names: names_payload(location),
          region: region_payload(location)
        }
      end

      def areas_payload(location)
        location.location_areas.order(:id).map do |location_area|
          {
            name: location_area.name,
            url: canonical_location_area_url(location_area)
          }
        end
      end

      def game_indices_payload(location)
        location.location_game_indices.includes(:generation).filter_map do |row|
          generation = row.generation
          next unless generation

          {
            game_index: row.game_index,
            generation: {
              name: generation.name,
              url: canonical_generation_url(generation)
            }
          }
        end
      end

      def names_payload(location)
        location.location_names.includes(:local_language).filter_map do |row|
          language = row.local_language
          next unless language

          {
            name: row.name,
            language: {
              name: language.name,
              url: canonical_language_url(language)
            }
          }
        end
      end

      def region_payload(location)
        region = location.region
        return nil unless region

        {
          name: region.name,
          url: canonical_region_url(region)
        }
      end

      def canonical_generation_url(generation)
        "#{api_v2_generation_url(generation).sub(%r{/+\z}, '')}/"
      end

      def canonical_language_url(language)
        "#{api_v2_language_url(language).sub(%r{/+\z}, '')}/"
      end

      def canonical_location_area_url(location_area)
        "#{api_v2_location_area_url(location_area).sub(%r{/+\z}, '')}/"
      end

      def canonical_region_url(region)
        "#{api_v2_region_url(region).sub(%r{/+\z}, '')}/"
      end
    end
  end
end
