module Api
  module V2
    class VersionGroupController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeVersionGroup
      RESOURCE_URL_HELPER = :api_v2_version_group_url

      private

      def detail_payload(version_group)
        {
          generation: generation_payload(version_group),
          id: version_group.id,
          move_learn_methods: move_learn_methods_payload(version_group),
          name: version_group.name,
          order: version_group.sort_order,
          pokedexes: pokedexes_payload(version_group),
          regions: regions_payload(version_group),
          versions: versions_payload(version_group)
        }
      end

      def generation_payload(version_group)
        generation = version_group.generation
        return nil unless generation

        resource_payload(generation, :api_v2_generation_url)
      end

      def move_learn_methods_payload(version_group)
        version_group.move_learn_methods.order(:id).map do |move_learn_method|
          resource_payload(move_learn_method, :api_v2_move_learn_method_url)
        end
      end

      def pokedexes_payload(version_group)
        version_group.pokedexes.order(:id).map do |pokedex|
          resource_payload(pokedex, :api_v2_pokedex_url)
        end
      end

      def regions_payload(version_group)
        version_group.regions.order(:id).map do |region|
          resource_payload(region, :api_v2_region_url)
        end
      end

      def versions_payload(version_group)
        version_group.versions.order(:id).map do |version|
          resource_payload(version, :api_v2_version_url)
        end
      end

      def resource_payload(record, route_helper)
        {
          name: record.name,
          url: "#{public_send(route_helper, record).sub(%r{/+\z}, '')}/"
        }
      end
    end
  end
end
