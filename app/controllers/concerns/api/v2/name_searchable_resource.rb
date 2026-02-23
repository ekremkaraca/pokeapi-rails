module Api
  module V2
    module NameSearchableResource
      extend ActiveSupport::Concern

      included do
        include IdOrNameLookup
        include Paginatable
        include QueryFilterable
      end

      def index
        scope = apply_q_filter(base_scope, column: q_filter_column)
        return unless stale_collection?(
          scope: scope,
          cache_key: "#{model_class.name.underscore}/index",
          variation: {
            q: params[:q].to_s.strip,
            limit: normalized_limit,
            offset: normalized_offset
          }
        )

        records, metadata = paginate(scope)

        render json: metadata.merge(results: records.map { |record| summary_payload(record) })
      end

      def show
        record = find_by_id_or_name!(model_scope, params[:id])
        return unless stale_resource?(record: record, cache_key: "#{model_class.name.underscore}/show")

        render json: detail_payload(record)
      end

      private

      def model_scope
        model_class.all
      end

      def base_scope
        model_scope.order(:id)
      end

      def summary_payload(record)
        {
          name: record.name,
          url: canonical_resource_url(record)
        }
      end

      def detail_payload(record)
        {
          id: record.id,
          name: record.name
        }.merge(detail_extras(record)).merge(url: canonical_resource_url(record))
      end

      def detail_extras(_record)
        {}
      end

      def q_filter_column
        :name
      end

      def model_class
        self.class::MODEL_CLASS
      end

      def canonical_resource_url(record)
        route_helper = self.class::RESOURCE_URL_HELPER
        "#{public_send(route_helper, record).sub(%r{/+\z}, '')}/"
      end
    end
  end
end
