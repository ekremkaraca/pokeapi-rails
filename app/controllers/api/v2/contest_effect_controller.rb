module Api
  module V2
    class ContestEffectController < BaseController
      include IdOnlyResource

      MODEL_CLASS = PokeContestEffect
      RESOURCE_URL_HELPER = :api_v2_contest_effect_url


      private

      def detail_extras(contest_effect)
        {
          appeal: contest_effect.appeal,
          jam: contest_effect.jam
        }
      end
    end
  end
end
