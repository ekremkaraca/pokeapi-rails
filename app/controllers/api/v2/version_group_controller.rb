module Api
  module V2
    class VersionGroupController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeVersionGroup
      RESOURCE_URL_HELPER = :api_v2_version_group_url

      private

      def detail_payload(version_group)
        {
          generation: generation_payload(version_group.generation_id),
          id: version_group.id,
          move_learn_methods: move_learn_methods_payload(version_group.id),
          name: version_group.name,
          order: version_group.sort_order,
          pokedexes: pokedexes_payload(version_group.id),
          regions: regions_payload(version_group.id),
          versions: versions_payload(version_group.id)
        }
      end

      def generation_payload(generation_id)
        generation = PokeGeneration.find_by(id: generation_id)
        return nil unless generation

        resource_payload(generation, :api_v2_generation_url)
      end

      def move_learn_methods_payload(version_group_id)
        method_ids = PokeVersionGroupPokemonMoveMethod.where(version_group_id: version_group_id).pluck(:pokemon_move_method_id).uniq
        PokeMoveLearnMethod.where(id: method_ids).order(:id).map do |move_learn_method|
          resource_payload(move_learn_method, :api_v2_move_learn_method_url)
        end
      end

      def pokedexes_payload(version_group_id)
        pokedex_ids = PokePokedexVersionGroup.where(version_group_id: version_group_id).pluck(:pokedex_id).uniq
        PokePokedex.where(id: pokedex_ids).order(:id).map do |pokedex|
          resource_payload(pokedex, :api_v2_pokedex_url)
        end
      end

      def regions_payload(version_group_id)
        region_ids = PokeVersionGroupRegion.where(version_group_id: version_group_id).pluck(:region_id).uniq
        PokeRegion.where(id: region_ids).order(:id).map do |region|
          resource_payload(region, :api_v2_region_url)
        end
      end

      def versions_payload(version_group_id)
        PokeVersion.where(version_group_id: version_group_id).order(:id).map do |version|
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
