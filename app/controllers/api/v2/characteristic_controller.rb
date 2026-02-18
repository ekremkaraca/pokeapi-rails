module Api
  module V2
    class CharacteristicController < BaseController
      include IdOnlyResource

      MODEL_CLASS = PokeCharacteristic
      RESOURCE_URL_HELPER = :api_v2_characteristic_url

      private

      def detail_extras(characteristic)
        {
          stat_id: characteristic.stat_id,
          gene_mod_5: characteristic.gene_mod_5
        }
      end
    end
  end
end
