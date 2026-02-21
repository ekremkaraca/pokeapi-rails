module Api
  module RateLimitHeaders
    extend ActiveSupport::Concern

    included do
      before_action :set_rate_limit_headers
    end

    private

    def set_rate_limit_headers
      sustained_limit = ENV.fetch("RACK_ATTACK_API_LIMIT", "300")
      sustained_period = ENV.fetch("RACK_ATTACK_API_PERIOD", "300")
      burst_limit = ENV.fetch("RACK_ATTACK_API_BURST_LIMIT", "60")
      burst_period = ENV.fetch("RACK_ATTACK_API_BURST_PERIOD", "60")

      response.set_header("X-RateLimit-Limit", sustained_limit)
      response.set_header("X-RateLimit-Period", sustained_period)
      response.set_header("X-RateLimit-Burst-Limit", burst_limit)
      response.set_header("X-RateLimit-Burst-Period", burst_period)
      response.set_header(
        "X-RateLimit-Policy",
        "sustained;limit=#{sustained_limit};window=#{sustained_period},burst;limit=#{burst_limit};window=#{burst_period}"
      )
    end
  end
end
