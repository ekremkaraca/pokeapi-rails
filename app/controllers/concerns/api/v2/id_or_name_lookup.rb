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
          lookup_by_name!(scope, lookup.downcase)
        else
          raise ActiveRecord::RecordNotFound
        end
      end

      def lookup_by_name!(scope, normalized_name)
        raise ActiveRecord::RecordNotFound if cached_name_miss?(scope.klass, normalized_name)

        primary_key = scope.klass.primary_key

        # Fast path for canonical lowercase names that can use a plain index.
        indexed_match = scope.where(name: normalized_name).order(primary_key => :asc).first
        return indexed_match if indexed_match

        table = scope.klass.arel_table
        lower_name = Arel::Nodes::NamedFunction.new("LOWER", [ table[:name] ])

        scope.where(lower_name.eq(normalized_name)).order(primary_key => :asc).first!
      rescue ActiveRecord::RecordNotFound
        cache_name_miss(scope.klass, normalized_name)
        raise
      end

      def cached_name_miss?(model_class, normalized_name)
        return false unless name_miss_cache_enabled?

        Rails.cache.exist?(name_miss_cache_key(model_class, normalized_name))
      end

      def cache_name_miss(model_class, normalized_name)
        return unless name_miss_cache_enabled?

        Rails.cache.write(name_miss_cache_key(model_class, normalized_name), true, expires_in: name_miss_cache_ttl)
      end

      def name_miss_cache_enabled?
        !Rails.cache.is_a?(ActiveSupport::Cache::NullStore) && name_miss_cache_ttl.positive?
      end

      def name_miss_cache_ttl
        ENV.fetch("API_V2_NAME_MISS_CACHE_TTL_SECONDS", "15").to_i.seconds
      end

      def name_miss_cache_key(model_class, normalized_name)
        "api/v2/name_miss/#{model_class.table_name}/#{normalized_name}"
      end
    end
  end
end
