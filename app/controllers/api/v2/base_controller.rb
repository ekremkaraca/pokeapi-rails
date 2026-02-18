module Api
  module V2
    class BaseController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

      private

      def render_not_found
        head :not_found
      end
    end
  end
end
