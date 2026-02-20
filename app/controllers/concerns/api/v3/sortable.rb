module Api
  module V3
    # Applies allowlisted sort directives from `sort=`.
    module Sortable
      private

      # Supports comma-separated fields and `-field` for descending order.
      # Returns [sorted_scope, canonical_sort_key] for cache variation.
      def apply_sort(scope, allowed:, default:)
        raw_sort = params[:sort].to_s.strip
        terms = raw_sort.empty? ? [ default ] : raw_sort.split(",").map(&:strip).reject(&:empty?)

        sort_pairs = terms.map do |term|
          direction = term.start_with?("-") ? :desc : :asc
          field = term.sub(/\A-/, "")
          [ field, direction ]
        end

        allowed_names = allowed.map(&:to_s)
        invalid_fields = sort_pairs.map(&:first).uniq - allowed_names
        if invalid_fields.any?
          raise BaseController::InvalidQueryParameterError.new(
            param: "sort",
            invalid_values: invalid_fields,
            allowed_values: allowed_names
          )
        end

        order_hash = sort_pairs.to_h.transform_keys(&:to_sym)
        [ scope.reorder(order_hash), terms.join(",") ]
      end
    end
  end
end
