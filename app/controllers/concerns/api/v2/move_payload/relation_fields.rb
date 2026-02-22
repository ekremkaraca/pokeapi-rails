module Api
  module V2
    module MovePayload
      module RelationFields
        extend ActiveSupport::Concern

        private

        def contest_combos_payload(move)
          normal_rows = move.contest_combos_as_first
          normal_reverse_rows = move.contest_combos_as_second
          super_rows = move.super_contest_combos_as_first
          super_reverse_rows = move.super_contest_combos_as_second

          {
            normal: {
              use_before: combo_moves(normal_rows, :second_move_id),
              use_after: combo_moves(normal_reverse_rows, :first_move_id)
            },
            super: {
              use_before: combo_moves(super_rows, :second_move_id),
              use_after: combo_moves(super_reverse_rows, :first_move_id)
            }
          }
        end

        def learned_by_pokemon_payload(move)
          move.pokemon_moves.includes(:pokemon).map(&:pokemon).compact.uniq.sort_by(&:id).map do |pokemon|
            resource_payload(pokemon, :api_v2_pokemon_url)
          end
        end

        def machines_payload(move)
          machines = move.machines.order(:id)
          version_groups_by_id = records_by_id(PokeVersionGroup, machines.map(&:version_group_id))

          machines.filter_map do |machine|
            version_group = version_groups_by_id[machine.version_group_id]
            next unless version_group

            {
              machine: { url: "#{api_v2_machine_url(machine).sub(%r{/+\z}, '')}/" },
              version_group: resource_payload(version_group, :api_v2_version_group_url)
            }
          end
        end

        def contest_effect_payload(move)
          contest_effect = move.contest_effect
          return nil unless contest_effect

          { url: "#{api_v2_contest_effect_url(contest_effect).sub(%r{/+\z}, '')}/" }
        end

        def contest_type_payload(move)
          contest_type = move.contest_type
          return nil unless contest_type

          resource_payload(contest_type, :api_v2_contest_type_url)
        end

        def damage_class_payload(move)
          damage_class = move.damage_class
          return nil unless damage_class

          resource_payload(damage_class, :api_v2_move_damage_class_url)
        end

        def generation_payload(move)
          generation = move.generation
          return nil unless generation

          resource_payload(generation, :api_v2_generation_url)
        end

        def super_contest_effect_payload(move)
          effect = move.super_contest_effect
          return nil unless effect

          { url: "#{api_v2_super_contest_effect_url(effect).sub(%r{/+\z}, '')}/" }
        end

        def target_payload(move)
          target = move.target
          return nil unless target

          resource_payload(target, :api_v2_move_target_url)
        end

        def type_payload(move)
          type = move.type
          return nil unless type

          resource_payload(type, :api_v2_type_url)
        end
      end
    end
  end
end
