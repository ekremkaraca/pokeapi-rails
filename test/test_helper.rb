ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors)

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
