module Api
  module V3
    class TypeController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeType.order(:id),
          cache_key: "v3/type#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        type = find_by_id_or_name!(PokeType.all, params[:id])
        render_show_flow(record: type, cache_key: "v3/type#show")
      end

      private

      def summary_fields
        %i[id name url pokemon]
      end

      def detail_fields
        %i[id name generation_id damage_class_id url pokemon]
      end

      def summary_includes
        %i[pokemon]
      end

      def detail_includes
        %i[pokemon]
      end

      def summary_include_map(records:, includes:)
        include_map_for_collection(records: records, includes: includes, include_key: :pokemon, loader: :pokemon_by_type_id)
      end

      def detail_include_map(record:, includes:)
        include_map_for_resource(record: record, includes: includes, include_key: :pokemon, loader: :pokemon_by_type_id)
      end

      def summary_payload(type, includes:, include_map:)
        payload = {
          id: type.id,
          name: type.name,
          url: canonical_url_for(type, :api_v3_type_url)
        }
        payload[:pokemon] = include_map.fetch(type.id, []) if includes.include?(:pokemon)
        payload
      end

      def detail_payload(type, includes:, include_map:)
        payload = {
          id: type.id,
          name: type.name,
          generation_id: type.generation_id,
          damage_class_id: type.damage_class_id,
          url: canonical_url_for(type, :api_v3_type_url)
        }
        payload[:pokemon] = include_map.fetch(type.id, []) if includes.include?(:pokemon)
        payload
      end
    end
  end
end
