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
        encounter_rows = PokeEncounter.where(pokemon_id: pokemon_id).to_a
        return [] if encounter_rows.empty?

        encounter_slot_ids = encounter_rows.map(&:encounter_slot_id).uniq
        slots_by_id = records_by_id(PokeEncounterSlot, encounter_slot_ids)

        encounter_ids = encounter_rows.map(&:id)
        condition_rows = PokeEncounterConditionValueMap.where(encounter_id: encounter_ids).to_a
        condition_rows_by_encounter = condition_rows.group_by(&:encounter_id)
        condition_values_by_id = records_by_id(
          PokeEncounterConditionValue,
          condition_rows.map(&:encounter_condition_value_id)
        )

        grouped_by_area = encounter_rows.group_by(&:location_area_id)
        location_areas_by_id = records_by_id(PokeLocationArea, grouped_by_area.keys)
        versions_by_id = records_by_id(PokeVersion, encounter_rows.map(&:version_id))
        methods_by_id = records_by_id(PokeEncounterMethod, slots_by_id.values.map(&:encounter_method_id))

        grouped_by_area.sort.map do |location_area_id, area_rows|
          location_area = location_areas_by_id[location_area_id]
          next unless location_area

          {
            location_area: resource_payload(location_area, :api_v2_location_area_url),
            version_details: version_details_payload(
              area_rows,
              slots_by_id,
              versions_by_id,
              methods_by_id,
              condition_rows_by_encounter,
              condition_values_by_id
            )
          }
        end.compact
      end

      def version_details_payload(area_rows, slots_by_id, versions_by_id, methods_by_id, condition_rows_by_encounter, condition_values_by_id)
        grouped_by_version = area_rows.group_by(&:version_id)

        grouped_by_version.sort.map do |version_id, version_rows|
          version = versions_by_id[version_id]
          next unless version

          {
            version: resource_payload(version, :api_v2_version_url),
            max_chance: max_chance_for(version_rows, slots_by_id),
            encounter_details: encounter_details_payload(
              version_rows,
              slots_by_id,
              methods_by_id,
              condition_rows_by_encounter,
              condition_values_by_id
            )
          }
        end.compact
      end

      def encounter_details_payload(version_rows, slots_by_id, methods_by_id, condition_rows_by_encounter, condition_values_by_id)
        version_rows.sort_by { |row| [row.encounter_slot_id, row.id] }.filter_map do |row|
          slot = slots_by_id[row.encounter_slot_id]
          next unless slot

          method = methods_by_id[slot.encounter_method_id]
          next unless method

          encounter_id = row.id
          condition_values = condition_values_payload(
            condition_rows_by_encounter[encounter_id],
            condition_values_by_id
          )

          {
            min_level: row.min_level,
            max_level: row.max_level,
            condition_values: condition_values,
            chance: slot.rarity,
            method: resource_payload(method, :api_v2_encounter_method_url)
          }
        end
      end

      def condition_values_payload(condition_rows, condition_values_by_id)
        rows = Array(condition_rows)

        rows.sort_by(&:encounter_condition_value_id).filter_map do |row|
          condition_value = condition_values_by_id[row.encounter_condition_value_id]
          next unless condition_value

          resource_payload(condition_value, :api_v2_encounter_condition_value_url)
        end
      end

      def max_chance_for(version_rows, slots_by_id)
        chances = version_rows.map do |row|
          slot = slots_by_id[row.encounter_slot_id]
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

      def records_by_id(model_class, ids)
        model_class.where(id: ids.uniq).index_by(&:id)
      end
    end
  end
end
