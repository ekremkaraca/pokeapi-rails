module Api
  module V2
    module QueryFilterable
      MAX_QUERY_LENGTH = 100

      private

      def apply_q_filter(scope, column: :name)
        query = params[:q].to_s.strip
        return scope if query.empty?

        # Prevent DoS attacks with very long query strings
        if query.length > MAX_QUERY_LENGTH
          raise ActiveRecord::RecordNotFound, "Query parameter too long"
        end

        escaped_query = ActiveRecord::Base.sanitize_sql_like(query)
        scope.where(scope.klass.arel_table[column.to_sym].matches("%#{escaped_query}%"))
      end
    end
  end
end
