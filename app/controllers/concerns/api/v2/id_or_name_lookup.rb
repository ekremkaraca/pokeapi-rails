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
          scope.find_by!("LOWER(name) = ?", lookup.downcase)
        else
          raise ActiveRecord::RecordNotFound
        end
      end
    end
  end
end
