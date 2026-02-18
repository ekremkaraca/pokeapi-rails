module Api
  module V2
    class LocationController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeLocation
      RESOURCE_URL_HELPER = :api_v2_location_url

      private

      def detail_payload(location)
        {
          areas: areas_payload(location.id),
          game_indices: game_indices_payload(location.id),
          id: location.id,
          name: location.name,
          names: names_payload(location.id),
          region: region_payload(location.region_id)
        }
      end

      def areas_payload(location_id)
        PokeLocationArea.where(location_id: location_id).order(:id).map do |location_area|
          {
            name: location_area.name,
            url: canonical_location_area_url(location_area)
          }
        end
      end

      def game_indices_payload(location_id)
        rows = PokeLocationGameIndex.where(location_id: location_id)
        generations_by_id = records_by_id(PokeGeneration, rows.map(&:generation_id))

        rows.filter_map do |row|
          generation = generations_by_id[row.generation_id]
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

      def names_payload(location_id)
        rows = PokeLocationName.where(location_id: location_id)
        languages_by_id = records_by_id(PokeLanguage, rows.map(&:local_language_id))

        rows.filter_map do |row|
          language = languages_by_id[row.local_language_id]
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

      def region_payload(region_id)
        region = PokeRegion.find_by(id: region_id)
        return nil unless region

        {
          name: region.name,
          url: canonical_region_url(region)
        }
      end

      def records_by_id(model_class, ids)
        model_class.where(id: ids.uniq).index_by(&:id)
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
