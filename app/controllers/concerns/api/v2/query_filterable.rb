module Api
  module V2
    module QueryFilterable
      private

      def apply_q_filter(scope, column: :name)
        query = params[:q].to_s.strip
        return scope if query.empty?

        escaped_query = ActiveRecord::Base.sanitize_sql_like(query)
        scope.where(scope.klass.arel_table[column.to_sym].matches("%#{escaped_query}%"))
      end
    end
  end
end
