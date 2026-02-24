require "ipaddr"

module Pokeapi
  module Network
    module ClientIp
      class << self
        def from_request(request)
          candidates_for(request).find { |ip| public_ip?(ip) } || request&.ip
        end

        private

        def candidates_for(request)
          [
            header_value(request, "HTTP_CF_CONNECTING_IP"),
            first_forwarded_ip(request)
          ].compact.uniq
        end

        def header_value(request, key)
          value = request&.get_header(key).to_s.strip
          return nil if value.empty?
          return nil unless valid_ip?(value)

          value
        end

        def first_forwarded_ip(request)
          raw = request&.get_header("HTTP_X_FORWARDED_FOR").to_s
          return nil if raw.strip.empty?

          raw.split(",").map(&:strip).find { |value| valid_ip?(value) }
        end

        def valid_ip?(value)
          IPAddr.new(value)
          true
        rescue IPAddr::InvalidAddressError
          false
        end

        def public_ip?(value)
          ip = IPAddr.new(value)
          return false if ip.loopback?
          return false if ip.link_local?
          return false if ip.private?

          if ip.ipv4?
            return false if ip == IPAddr.new("0.0.0.0/8")
            return false if ip == IPAddr.new("169.254.0.0/16")
          end

          true
        rescue IPAddr::InvalidAddressError
          false
        end
      end
    end
  end
end
