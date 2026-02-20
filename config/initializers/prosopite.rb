begin
  require "prosopite"
rescue LoadError
  # Gem not installed in this environment.
end

return unless defined?(Prosopite)

Rails.application.configure do
  config.after_initialize do
    default_enabled = Rails.env.development? || Rails.env.test?

    Prosopite.enabled = ENV.fetch("PROSOPITE_ENABLED", default_enabled ? "1" : "0") == "1"
    Prosopite.min_n_queries = ENV.fetch("PROSOPITE_MIN_N_QUERIES", "2").to_i
    Prosopite.rails_logger = ENV.fetch("PROSOPITE_RAILS_LOGGER", Rails.env.development? ? "1" : "0") == "1"
    Prosopite.raise = ENV.fetch("PROSOPITE_RAISE", "0") == "1"
  end
end

# Auto-scan controller requests in development.
if Rails.env.development? && ENV.fetch("PROSOPITE_RACK_MIDDLEWARE", "1") == "1"
  require "prosopite/middleware/rack"
  Rails.application.config.middleware.use(Prosopite::Middleware::Rack)
end
