module Api
  module V3
    # Shared relation loaders for include expansions.
    # Each loader returns a hash keyed by primary resource id.
    module IncludeLoaders
      extend ActiveSupport::Concern
      MAX_INCLUDED_POKEMON_PER_MOVE = 25

      included do
        include PokemonLoaders
        include RelationLoaders
        include ItemLoaders
        include LocationLoaders
      end

      private

      # Canonical compact object used for nested resource references.
      def resource_ref(record, route_helper)
        {
          id: record.id,
          name: record.name,
          url: canonical_url_for(record, route_helper)
        }
      end

      # Normalizes URL helper output to the API convention with trailing slash.
      def canonical_url_for(record, route_helper)
        "#{public_send(route_helper, record).sub(%r{/+\z}, '')}/"
      end

      def canonical_url_for_id(id, route_helper)
        "#{public_send(route_helper, id).sub(%r{/+\z}, '')}/"
      end
    end
  end
end
