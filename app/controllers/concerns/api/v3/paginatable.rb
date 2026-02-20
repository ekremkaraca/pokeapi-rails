module Api
  module V3
    # Shared offset pagination behavior for v3 collection endpoints.
    # Produces PokeAPI-style list metadata: count/next/previous.
    module Paginatable
      DEFAULT_LIMIT = 20
      MAX_LIMIT = 100

      private

      # Returns [relation, metadata_hash] after applying validated limit/offset.
      def paginate(scope)
        limit = normalized_limit
        offset = normalized_offset
        total_count = scope.count

        paginated_scope = scope.limit(limit).offset(offset)
        [ paginated_scope, pagination_meta(total_count: total_count, limit: limit, offset: offset) ]
      end

      # Normalizes `limit` and clamps it to MAX_LIMIT.
      def normalized_limit
        value = params[:limit].to_i
        return DEFAULT_LIMIT if value <= 0

        [ value, MAX_LIMIT ].min
      end

      # Normalizes `offset`, never allowing negative values.
      def normalized_offset
        value = params[:offset].to_i
        return 0 if value.negative?

        value
      end

      # Builds the list envelope metadata.
      def pagination_meta(total_count:, limit:, offset:)
        {
          count: total_count,
          next: next_page_url(total_count: total_count, limit: limit, offset: offset),
          previous: previous_page_url(limit: limit, offset: offset)
        }
      end

      # Returns next page URL or nil when current page is terminal.
      def next_page_url(total_count:, limit:, offset:)
        next_offset = offset + limit
        return nil if next_offset >= total_count

        build_page_url(limit: limit, offset: next_offset)
      end

      # Returns previous page URL or nil when on first page.
      def previous_page_url(limit:, offset:)
        return nil if offset <= 0

        previous_offset = [ offset - limit, 0 ].max
        build_page_url(limit: limit, offset: previous_offset)
      end

      # Reconstructs current request URL with updated pagination params.
      def build_page_url(limit:, offset:)
        merged_query = request.query_parameters.merge("limit" => limit.to_s, "offset" => offset.to_s)
        query_string = Rack::Utils.build_query(merged_query)
        "#{request.base_url}#{request.path}?#{query_string}"
      end
    end
  end
end
