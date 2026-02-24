ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "support/env_helpers"
require_relative "support/integration_query_assertions"
require_relative "support/cache_helpers"
require_relative "support/sql_capture_helpers"

class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors)
  include EnvHelpers
  include CacheHelpers
  include SqlCaptureHelpers

  setup do
    next unless ENV["PROSOPITE_TEST_SCAN"] == "1"
    next unless defined?(Prosopite)

    Prosopite.scan
  end

  teardown do
    next unless ENV["PROSOPITE_TEST_SCAN"] == "1"
    next unless defined?(Prosopite)

    Prosopite.finish
  end
end

class ActionDispatch::IntegrationTest
  include IntegrationQueryAssertions
end
