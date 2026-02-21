module Api
  module V2
    class PokemonEncountersController < BaseController
      def show
        lookup = params[:id].to_s
        raise ActiveRecord::RecordNotFound unless /\A\d+\z/.match?(lookup)

        pokemon = Pokemon.find(lookup.to_i)
        render json: encounters_payload(pokemon.id)
      end

      private

      def encounters_payload(pokemon_id)
        encounter_rows = PokeEncounter
          .where(pokemon_id: pokemon_id)
          .includes(
            :location_area,
            :version,
            encounter_slot: :encounter_method,
            encounter_condition_value_maps: :encounter_condition_value
          )
          .to_a
        return [] if encounter_rows.empty?

        grouped_by_area = encounter_rows.group_by(&:location_area_id)

        grouped_by_area.sort.map do |location_area_id, area_rows|
          location_area = area_rows.first&.location_area
          next unless location_area

          {
            location_area: resource_payload(location_area, :api_v2_location_area_url),
            version_details: version_details_payload(area_rows)
          }
        end.compact
      end

      def version_details_payload(area_rows)
        grouped_by_version = area_rows.group_by(&:version_id)

        grouped_by_version.sort.map do |version_id, version_rows|
          version = version_rows.first&.version
          next unless version

          {
            version: resource_payload(version, :api_v2_version_url),
            max_chance: max_chance_for(version_rows),
            encounter_details: encounter_details_payload(version_rows)
          }
        end.compact
      end

      def encounter_details_payload(version_rows)
        version_rows.sort_by { |row| [ row.encounter_slot_id, row.id ] }.filter_map do |row|
          slot = row.encounter_slot
          next unless slot

          method = slot.encounter_method
          next unless method

          condition_values = condition_values_payload(row.encounter_condition_value_maps)

          {
            min_level: row.min_level,
            max_level: row.max_level,
            condition_values: condition_values,
            chance: slot.rarity,
            method: resource_payload(method, :api_v2_encounter_method_url)
          }
        end
      end

      def condition_values_payload(condition_maps)
        Array(condition_maps).sort_by(&:encounter_condition_value_id).filter_map do |row|
          condition_value = row.encounter_condition_value
          next unless condition_value

          resource_payload(condition_value, :api_v2_encounter_condition_value_url)
        end
      end

      def max_chance_for(version_rows)
        chances = version_rows.map do |row|
          slot = row.encounter_slot
          slot ? slot.rarity : 0
        end

        chances.max || 0
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
