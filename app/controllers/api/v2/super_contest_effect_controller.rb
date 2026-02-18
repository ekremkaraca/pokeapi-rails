module Api
  module V2
    class SuperContestEffectController < BaseController
      include IdOnlyResource

      MODEL_CLASS = PokeSuperContestEffect
      RESOURCE_URL_HELPER = :api_v2_super_contest_effect_url


      private

      def detail_extras(super_contest_effect)
        {
          appeal: super_contest_effect.appeal
        }
      end
    end
  end
end
