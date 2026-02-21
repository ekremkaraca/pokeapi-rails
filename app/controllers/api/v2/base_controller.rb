module Api
  module V2
    class BaseController < ActionController::API
      include Api::RateLimitHeaders
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      before_action :force_json_format

      private

      def force_json_format
        request.format = :json
      end

      def render_not_found
        head :not_found
      end
    end
  end
end
