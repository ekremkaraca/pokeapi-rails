module Api
  module V2
    module Paginatable
      DEFAULT_LIMIT = 20
      MAX_LIMIT = 100

      private

      def paginate(scope)
        limit = normalized_limit
        offset = normalized_offset
        total_count = scope.count

        paginated_scope = scope.limit(limit).offset(offset)
        [ paginated_scope, pagination_meta(total_count: total_count, limit: limit, offset: offset) ]
      end

      def normalized_limit
        value = params[:limit].to_i
        return DEFAULT_LIMIT if value <= 0

        [ value, MAX_LIMIT ].min
      end

      def normalized_offset
        value = params[:offset].to_i
        return 0 if value.negative?

        value
      end

      def pagination_meta(total_count:, limit:, offset:)
        {
          count: total_count,
          next: next_page_url(total_count: total_count, limit: limit, offset: offset),
          previous: previous_page_url(limit: limit, offset: offset)
        }
      end

      def next_page_url(total_count:, limit:, offset:)
        next_offset = offset + limit
        return nil if next_offset >= total_count

        build_page_url(limit: limit, offset: next_offset)
      end

      def previous_page_url(limit:, offset:)
        return nil if offset <= 0

        previous_offset = [offset - limit, 0].max
        build_page_url(limit: limit, offset: previous_offset)
      end

      def build_page_url(limit:, offset:)
        merged_query = request.query_parameters.merge("limit" => limit.to_s, "offset" => offset.to_s)
        query_string = Rack::Utils.build_query(merged_query)
        "#{request.base_url}#{request.path}?#{query_string}"
      end
    end
  end
end
