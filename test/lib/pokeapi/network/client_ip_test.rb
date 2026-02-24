require "test_helper"
require Rails.root.join("lib/pokeapi/network/client_ip")

module Pokeapi
  module Network
    class ClientIpTest < ActiveSupport::TestCase
      Request = Struct.new(:ip, :headers, keyword_init: true) do
        def get_header(key)
          headers&.[](key)
        end
      end

      test "prefers cloudflare connecting ip when present and public" do
        request = Request.new(
          ip: "172.69.109.75",
          headers: { "HTTP_CF_CONNECTING_IP" => "198.51.100.7" }
        )

        assert_equal "198.51.100.7", ClientIp.from_request(request)
      end

      test "falls back to first forwarded ip when cloudflare header is missing" do
        request = Request.new(
          ip: "172.69.109.75",
          headers: { "HTTP_X_FORWARDED_FOR" => "203.0.113.11, 172.69.109.75" }
        )

        assert_equal "203.0.113.11", ClientIp.from_request(request)
      end

      test "falls back to rack request ip when forwarded headers are missing/invalid" do
        request = Request.new(
          ip: "203.0.113.99",
          headers: { "HTTP_CF_CONNECTING_IP" => "invalid-ip", "HTTP_X_FORWARDED_FOR" => "" }
        )

        assert_equal "203.0.113.99", ClientIp.from_request(request)
      end
    end
  end
end
