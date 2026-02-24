module Api
  module V2
    class MoveController < BaseController
      include NameSearchableResource
      include MoveDetailPayload

      MODEL_CLASS = PokeMove
      RESOURCE_URL_HELPER = :api_v2_move_url

      def show
        record = find_by_id_or_name!(detail_scope, params[:id])
        return unless stale_resource?(record: record, cache_key: "#{model_class.name.underscore}/show")

        payload = cached_json_payload("api/v2/move/show/#{record.cache_key_with_version}") do
          detail_payload(record)
        end

        render json: payload
      end

      private

      def model_scope
        PokeMove.all
      end

      def detail_scope
        PokeMove.preload(
          :contest_effect,
          :contest_type,
          :damage_class,
          :generation,
          :super_contest_effect,
          :target,
          :type,
          :move_names,
          :move_effect_proses,
          :move_flavor_texts,
          :move_changelogs,
          :contest_combos_as_first,
          :contest_combos_as_second,
          :super_contest_combos_as_first,
          :super_contest_combos_as_second,
          :machines,
          :pokemon_moves,
          :move_effect_changelogs,
          :move_meta,
          :move_meta_stat_changes
        )
      end
    end
  end
end
