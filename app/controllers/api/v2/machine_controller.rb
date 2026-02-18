module Api
  module V2
    class MachineController < BaseController
      include IdOnlyResource

      MODEL_CLASS = PokeMachine
      RESOURCE_URL_HELPER = :api_v2_machine_url

      private

      def detail_extras(machine)
        {
          machine_number: machine.machine_number,
          version_group_id: machine.version_group_id,
          item_id: machine.item_id,
          move_id: machine.move_id
        }
      end
    end
  end
end
