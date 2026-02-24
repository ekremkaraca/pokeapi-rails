module Api
  module V2
    module IdOrNameLookup
      ID_PATTERN = /\A-?\d+\z/
      NAME_PATTERN = /\A[0-9A-Za-z\-\+ ]+\z/
      MAX_INT_32 = 2_147_483_647

      private

      def find_by_id_or_name!(scope, lookup)
        if ID_PATTERN.match?(lookup)
          lookup_id = lookup.to_i
          raise ActiveRecord::RecordNotFound if lookup_id.abs > MAX_INT_32

          scope.find(lookup_id)
        elsif NAME_PATTERN.match?(lookup)
          normalized_name = lookup.downcase
          primary_key = scope.klass.primary_key

          # Fast path for canonical lowercase names that can use a plain index.
          indexed_match = scope.where(name: normalized_name).order(primary_key => :asc).first
          return indexed_match if indexed_match

          table = scope.klass.arel_table
          lower_name = Arel::Nodes::NamedFunction.new("LOWER", [ table[:name] ])

          scope.where(lower_name.eq(normalized_name)).order(primary_key => :asc).first!
        else
          raise ActiveRecord::RecordNotFound
        end
      end
    end
  end
end
