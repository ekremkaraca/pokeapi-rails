module Api
  module V3
    class MachineController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        machine_table = PokeMachine.arel_table
        render_index_flow(
          scope: PokeMachine.order(:id),
          cache_key: "v3/machine#index",
          sort_allowed: %i[id machine_number],
          sort_default: "id",
          q_column: Arel::Nodes::NamedFunction.new(
            "CONCAT",
            [ Arel::Nodes.build_quoted("machine-"), machine_table[:id] ]
          )
        )
      end

      def show
        machine = PokeMachine.find(require_numeric_id!(params[:id]))
        render_show_flow(record: machine, cache_key: "v3/machine#show")
      end

      private

      def summary_fields
        %i[id name machine_number version_group_id item_id move_id url item]
      end

      def detail_fields
        %i[id name machine_number version_group_id item_id move_id url item]
      end

      def summary_includes
        %i[item]
      end

      def detail_includes
        %i[item]
      end

      def summary_include_map(records:, includes:)
        include_map_for_collection(records: records, includes: includes, include_key: :item, loader: :item_by_machine_id)
      end

      def detail_include_map(record:, includes:)
        include_map_for_resource(record: record, includes: includes, include_key: :item, loader: :item_by_machine_id)
      end

      def summary_payload(machine, includes:, include_map:)
        payload = {
          id: machine.id,
          name: synthetic_name_for(machine.id),
          machine_number: machine.machine_number,
          version_group_id: machine.version_group_id,
          item_id: machine.item_id,
          move_id: machine.move_id,
          url: canonical_url_for(machine, :api_v3_machine_url)
        }
        payload[:item] = include_map[machine.id] if includes.include?(:item)
        payload
      end

      def detail_payload(machine, includes:, include_map:)
        payload = {
          id: machine.id,
          name: synthetic_name_for(machine.id),
          machine_number: machine.machine_number,
          version_group_id: machine.version_group_id,
          item_id: machine.item_id,
          move_id: machine.move_id,
          url: canonical_url_for(machine, :api_v3_machine_url)
        }
        payload[:item] = include_map[machine.id] if includes.include?(:item)
        payload
      end

      def apply_filter_params(scope, allowed:)
        filters = normalized_filter_params(allowed: allowed)
        table = scope.klass.arel_table
        # Use Arel for computed-name filtering to avoid raw SQL string interpolation.
        name_column = Arel::Nodes::NamedFunction.new(
          "CONCAT",
          [ Arel::Nodes.build_quoted("machine-"), table[:id] ]
        )

        filters.reduce(scope) do |current_scope, (field, value)|
          if field == "name"
            current_scope.where(Arel::Nodes::InfixOperation.new("ILIKE", name_column, Arel::Nodes.build_quoted(value)))
          else
            current_scope.where(table[field.to_sym].matches(value))
          end
        end
      end

      def synthetic_name_for(id)
        "machine-#{id}"
      end
    end
  end
end
