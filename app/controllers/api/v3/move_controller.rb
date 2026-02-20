module Api
  module V3
    class MoveController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeMove.order(:id),
          cache_key: "v3/move#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        move = PokeMove.find(require_numeric_id!(params[:id]))
        render_show_flow(record: move, cache_key: "v3/move#show")
      end

      private

      def summary_fields
        %i[id name url power]
      end

      def detail_fields
        %i[id name url accuracy power pp priority type_id damage_class_id target_id pokemon]
      end

      def summary_includes
        %i[pokemon]
      end

      def detail_includes
        %i[pokemon]
      end

      def summary_include_map(records:, includes:)
        include_map_for_collection(records: records, includes: includes, include_key: :pokemon, loader: :pokemon_by_move_id)
      end

      def detail_include_map(record:, includes:)
        include_map_for_resource(record: record, includes: includes, include_key: :pokemon, loader: :pokemon_by_move_id)
      end

      def summary_payload(move, includes:, include_map:)
        payload = {
          id: move.id,
          name: move.name,
          power: move.power,
          url: canonical_url_for(move, :api_v3_move_url)
        }
        payload[:pokemon] = include_map.fetch(move.id, []) if includes.include?(:pokemon)
        payload
      end

      def detail_payload(move, includes:, include_map:)
        payload = {
          id: move.id,
          name: move.name,
          accuracy: move.accuracy,
          power: move.power,
          pp: move.pp,
          priority: move.priority,
          type_id: move.type_id,
          damage_class_id: move.damage_class_id,
          target_id: move.target_id,
          url: canonical_url_for(move, :api_v3_move_url)
        }
        payload[:pokemon] = include_map.fetch(move.id, []) if includes.include?(:pokemon)
        payload
      end
    end
  end
end
