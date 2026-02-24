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

        render json: detail_payload(record)
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
          machines: :version_group,
          pokemon_moves: :pokemon,
          move_effect_changelogs: :proses,
          move_meta: %i[meta_ailment meta_category],
          move_meta_stat_changes: :stat
        )
      end
    end
  end
end
