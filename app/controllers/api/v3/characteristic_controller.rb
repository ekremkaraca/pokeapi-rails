module Api
  module V3
    class CharacteristicController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeCharacteristic.order(:id),
          cache_key: "v3/characteristic#index",
          sort_allowed: %i[id gene_mod_5 stat_id],
          sort_default: "id",
          q_column: "id::text",
          filter_allowed: []
        )
      end

      def show
        characteristic = PokeCharacteristic.find(require_numeric_id!(params[:id]))
        render_show_flow(record: characteristic, cache_key: "v3/characteristic#show")
      end

      private

      def summary_fields
        %i[id gene_mod_5 stat_id url]
      end

      def detail_fields
        %i[id gene_mod_5 stat_id url]
      end

      def summary_includes
        []
      end

      def detail_includes
        []
      end

      def summary_payload(characteristic, includes:, include_map:)
        {
          id: characteristic.id,
          gene_mod_5: characteristic.gene_mod_5,
          stat_id: characteristic.stat_id,
          url: canonical_url_for(characteristic, :api_v3_characteristic_url)
        }
      end

      def detail_payload(characteristic, includes:, include_map:)
        {
          id: characteristic.id,
          gene_mod_5: characteristic.gene_mod_5,
          stat_id: characteristic.stat_id,
          url: canonical_url_for(characteristic, :api_v3_characteristic_url)
        }
      end
    end
  end
end
