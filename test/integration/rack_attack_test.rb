require "test_helper"

class RackAttackTest < ActionDispatch::IntegrationTest
  setup do
    @original_enabled = Rack::Attack.enabled
    @original_limit = ENV["RACK_ATTACK_API_LIMIT"]
    @original_period = ENV["RACK_ATTACK_API_PERIOD"]
    @original_burst_limit = ENV["RACK_ATTACK_API_BURST_LIMIT"]
    @original_burst_period = ENV["RACK_ATTACK_API_BURST_PERIOD"]

    Rack::Attack.enabled = true
    ENV["RACK_ATTACK_API_LIMIT"] = "2"
    ENV["RACK_ATTACK_API_PERIOD"] = "60"
    ENV["RACK_ATTACK_API_BURST_LIMIT"] = "30"
    ENV["RACK_ATTACK_API_BURST_PERIOD"] = "60"
    Rack::Attack.cache.store.clear if Rack::Attack.cache.store.respond_to?(:clear)
  end

  teardown do
    Rack::Attack.enabled = @original_enabled
    ENV["RACK_ATTACK_API_LIMIT"] = @original_limit
    ENV["RACK_ATTACK_API_PERIOD"] = @original_period
    ENV["RACK_ATTACK_API_BURST_LIMIT"] = @original_burst_limit
    ENV["RACK_ATTACK_API_BURST_PERIOD"] = @original_burst_period
    Rack::Attack.cache.store.clear if Rack::Attack.cache.store.respond_to?(:clear)
  end

  test "throttles API traffic after configured limit" do
    get "/api/v3/"
    assert_response :success
    assert_equal "2", response.headers["X-RateLimit-Limit"]
    assert_equal "60", response.headers["X-RateLimit-Period"]
    assert_equal "30", response.headers["X-RateLimit-Burst-Limit"]
    assert_equal "60", response.headers["X-RateLimit-Burst-Period"]
    assert_match(/sustained;limit=2;window=60,burst;limit=30;window=60/, response.headers["X-RateLimit-Policy"].to_s)

    get "/api/v3/"
    assert_response :success

    get "/api/v3/"
    assert_response :too_many_requests

    payload = JSON.parse(response.body)
    assert_equal "rate_limited", payload.dig("error", "code")
    assert_match(/\A\d+\z/, response.headers["Retry-After"].to_s)
  end

  test "does not throttle healthcheck endpoint" do
    5.times do
      get "/up"
      assert_response :success
    end
  end

  test "includes rate-limit headers on v2 responses" do
    get "/api/v2/"
    assert_response :success
    assert_equal "2", response.headers["X-RateLimit-Limit"]
    assert_equal "60", response.headers["X-RateLimit-Period"]
    assert_equal "30", response.headers["X-RateLimit-Burst-Limit"]
    assert_equal "60", response.headers["X-RateLimit-Burst-Period"]
  end

  test "throttles bursts with short-window rule" do
    ENV["RACK_ATTACK_API_LIMIT"] = "100"
    ENV["RACK_ATTACK_API_PERIOD"] = "300"
    ENV["RACK_ATTACK_API_BURST_LIMIT"] = "1"
    ENV["RACK_ATTACK_API_BURST_PERIOD"] = "60"
    Rack::Attack.cache.store.clear if Rack::Attack.cache.store.respond_to?(:clear)

    get "/api/v3/"
    assert_response :success

    get "/api/v3/"
    assert_response :too_many_requests
  end
end
