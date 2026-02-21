class Rack::Attack
  class << self
    def enabled_by_default?
      Rails.env.production?
    end

    def enabled_from_env?
      value = ENV["RACK_ATTACK_ENABLED"]
      return enabled_by_default? if value.nil?

      ActiveModel::Type::Boolean.new.cast(value)
    end
  end

  self.enabled = enabled_from_env?
  cache_store = Rails.cache
  cache_store = ActiveSupport::Cache::MemoryStore.new if cache_store.is_a?(ActiveSupport::Cache::NullStore)
  Rack::Attack.cache.store = cache_store

  API_PATH_PREFIX = "/api/".freeze
  HEALTHCHECK_PATH = "/up".freeze
  API_LIMIT = ->(_req) { ENV.fetch("RACK_ATTACK_API_LIMIT", "300").to_i }
  API_PERIOD = ->(_req) { ENV.fetch("RACK_ATTACK_API_PERIOD", "300").to_i }
  API_BURST_LIMIT = ->(_req) { ENV.fetch("RACK_ATTACK_API_BURST_LIMIT", "60").to_i }
  API_BURST_PERIOD = ->(_req) { ENV.fetch("RACK_ATTACK_API_BURST_PERIOD", "60").to_i }

  safelist("allow-healthcheck") do |req|
    req.path == HEALTHCHECK_PATH
  end

  throttle("api/ip", limit: API_LIMIT, period: API_PERIOD) do |req|
    req.ip if req.path.start_with?(API_PATH_PREFIX)
  end

  throttle("api/ip/burst", limit: API_BURST_LIMIT, period: API_BURST_PERIOD) do |req|
    req.ip if req.path.start_with?(API_PATH_PREFIX)
  end

  self.throttled_responder = lambda do |req|
    now = Time.now.utc
    match_data = req.env["rack.attack.match_data"] || {}
    retry_after = match_data[:period].to_i

    headers = {
      "Content-Type" => "application/json",
      "Retry-After" => retry_after.to_s,
      "X-RateLimit-Limit" => match_data[:limit].to_s,
      "X-RateLimit-Reset" => (now.to_i + retry_after).to_s
    }

    [ 429, headers, [ { error: { code: "rate_limited", message: "Too many requests" } }.to_json ] ]
  end

  ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |_name, _start, _finish, _id, payload|
    request = payload[:request]
    Rails.logger.warn(
      "[rack-attack] throttle=#{payload[:match_type]} rule=#{payload[:match_discriminator]} ip=#{request.ip} path=#{request.path}"
    )
  end
end
