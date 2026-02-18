module Api
  module V2
    module IdOnlyResource
      extend ActiveSupport::Concern

      included do
        include Paginatable
      end

      ID_PATTERN = /\A-?\d+\z/
      MAX_INT_32 = 2_147_483_647

      def index
        records, metadata = paginate(base_scope)
        render json: metadata.merge(results: records.map { |record| summary_payload(record) })
      end

      def show
        record = find_by_id!(model_scope, params[:id])
        render json: detail_payload(record)
      end

      private

      def model_scope
        model_class.all
      end

      def base_scope
        model_scope.order(:id)
      end

      def find_by_id!(scope, lookup)
        raise ActiveRecord::RecordNotFound unless ID_PATTERN.match?(lookup)

        lookup_id = lookup.to_i
        raise ActiveRecord::RecordNotFound if lookup_id.abs > MAX_INT_32

        scope.find(lookup_id)
      end

      def summary_payload(record)
        {
          url: canonical_resource_url(record)
        }
      end

      def detail_payload(record)
        {
          id: record.id
        }.merge(detail_extras(record)).merge(url: canonical_resource_url(record))
      end

      def detail_extras(_record)
        {}
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
