module Api
  module V3
    # Implements a simple case-insensitive name search via `q`.
    module QueryFilterable
      private

      # Applies `ILIKE %q%` filtering against a safe SQL-escaped value.
      def apply_q_filter(scope, column: :name)
        query = params[:q].to_s.strip
        return scope if query.empty?

        escaped_query = ActiveRecord::Base.sanitize_sql_like(query)
        pattern = "%#{escaped_query}%"

        case column
        when Symbol
          scope.where(scope.klass.arel_table[column].matches(pattern))
        when Arel::Attributes::Attribute, Arel::Nodes::Node, Arel::Nodes::SqlLiteral
          scope.where(Arel::Nodes::InfixOperation.new("ILIKE", column, Arel::Nodes.build_quoted(pattern)))
        else
          raise ArgumentError, "Unsupported q filter column: #{column.inspect}"
        end
      end

      # Applies allowlisted exact-match filters from `filter[field]=value`.
      # Unknown filter fields raise InvalidQueryParameterError.
      def apply_filter_params(scope, allowed:)
        filters = normalized_filter_params(allowed: allowed)
        table = scope.klass.arel_table

        filters.reduce(scope) do |current_scope, (field, value)|
          current_scope.where(table[field.to_sym].matches(value))
        end
      end

      # Canonical filter map used in cache variation keys.
      def filter_variation(allowed:)
        normalized_filter_params(allowed: allowed)
      end

      def normalized_filter_params(allowed:)
        raw_filter = params[:filter]
        return {} if raw_filter.blank?

        filter_hash =
          case raw_filter
          when ActionController::Parameters
            raw_filter.to_unsafe_h
          when Hash
            raw_filter
          else
            {}
          end

        allowed_names = allowed.map(&:to_s)
        requested_keys = filter_hash.keys.map(&:to_s).uniq
        invalid_keys = requested_keys - allowed_names

        if invalid_keys.any?
          raise BaseController::InvalidQueryParameterError.new(
            param: "filter",
            invalid_values: invalid_keys,
            allowed_values: allowed_names
          )
        end

        filter_hash.each_with_object({}) do |(key, value), normalized|
          next if value.nil?

          normalized_value = value.to_s.strip
          next if normalized_value.empty?

          normalized[key.to_s] = normalized_value
        end.sort.to_h
      end
    end
  end
end
