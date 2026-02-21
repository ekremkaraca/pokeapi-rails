module Api
  module V2
    class BaseController < ActionController::API
      include Api::RateLimitHeaders
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

      private

      def render_not_found
        head :not_found
      end
    end
  end
end
