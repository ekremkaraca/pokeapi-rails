require "digest/sha1"
require Rails.root.join("lib/pokeapi/network/client_ip")

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
  NON_API_LIMIT = ->(_req) { ENV.fetch("RACK_ATTACK_NON_API_LIMIT", "30").to_i }
  NON_API_PERIOD = ->(_req) { ENV.fetch("RACK_ATTACK_NON_API_PERIOD", "60").to_i }
  V2_SHOW_PERIOD = ENV.fetch("RACK_ATTACK_V2_SHOW_PERIOD", "60").to_i
  V2_SHOW_LIMIT = ENV.fetch("RACK_ATTACK_V2_SHOW_LIMIT", "20").to_i

  SAFE_NON_API_PATHS = [
    "/",
    "/favicon.ico",
    "/icon.png",
    HEALTHCHECK_PATH
  ].freeze

  MALICIOUS_PATH_PATTERN = %r{
    \A/
    (?:
      \.git(?:/|$)|
      \.env(?:$|/)|
      wp-admin(?:/|$)|
      wp-login\.php$|
      xmlrpc\.php$|
      server-status$|
      server-info$|
      vendor/phpunit(?:/|$)|
      .*\.php$
    )
  }ix.freeze

  def self.client_ip_for(req)
    Pokeapi::Network::ClientIp.from_request(req)
  end

  safelist("allow-healthcheck") do |req|
    req.path == HEALTHCHECK_PATH
  end

  blocklist("malicious-path-probes") do |req|
    req.path.to_s.match?(MALICIOUS_PATH_PATTERN)
  end

  throttle("api/ip", limit: API_LIMIT, period: API_PERIOD) do |req|
    client_ip_for(req) if req.path.start_with?(API_PATH_PREFIX)
  end

  throttle("api/ip/burst", limit: API_BURST_LIMIT, period: API_BURST_PERIOD) do |req|
    client_ip_for(req) if req.path.start_with?(API_PATH_PREFIX)
  end

  throttle("non_api/ip", limit: NON_API_LIMIT, period: NON_API_PERIOD) do |req|
    next if req.path.start_with?(API_PATH_PREFIX)
    next if SAFE_NON_API_PATHS.include?(req.path)

    client_ip_for(req)
  end

  if V2_SHOW_LIMIT.positive?
    throttle("api/v2/show/ip", limit: V2_SHOW_LIMIT, period: V2_SHOW_PERIOD) do |req|
      next unless req.get? || req.head?
      next unless req.path.match?(%r{\A/api/v2/[^/]+/[^/]+/?\z})

      client_ip_for(req)
    end
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
    ua_sha1 = Digest::SHA1.hexdigest(request.user_agent.to_s)
    client_ip = client_ip_for(request)
    Rails.logger.warn(
      "[rack-attack] throttle=#{payload[:match_type]} rule=#{payload[:match_discriminator]} " \
      "host=#{request.host} method=#{request.request_method} ip=#{client_ip} " \
      "ua_sha1=#{ua_sha1} path=#{request.path}"
    )
  end
end
