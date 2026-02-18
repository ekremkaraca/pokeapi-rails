require "json"
require "net/http"
require "uri"

module Pokeapi
  module Parity
    class ResponseDiff
      PROFILE_SMOKE = "smoke".freeze
      PROFILE_CORE = "core".freeze
      PROFILE_FULL = "full".freeze
      VALID_PROFILES = [PROFILE_SMOKE, PROFILE_CORE, PROFILE_FULL].freeze

      ROOT_PATH = "/api/v2/".freeze
      RESOURCE_SLUGS = [
        "ability",
        "berry",
        "berry-firmness",
        "berry-flavor",
        "characteristic",
        "contest-type",
        "contest-effect",
        "evolution-chain",
        "evolution-trigger",
        "encounter-method",
        "encounter-condition",
        "egg-group",
        "encounter-condition-value",
        "generation",
        "gender",
        "growth-rate",
        "item",
        "item-attribute",
        "item-category",
        "item-fling-effect",
        "item-pocket",
        "language",
        "location",
        "location-area",
        "machine",
        "move",
        "move-damage-class",
        "move-ailment",
        "move-battle-style",
        "move-category",
        "move-learn-method",
        "move-target",
        "nature",
        "pokedex",
        "pokemon-color",
        "pokemon-form",
        "pokemon-habitat",
        "pokemon-shape",
        "pokemon-species",
        "pokeathlon-stat",
        "region",
        "stat",
        "super-contest-effect",
        "type",
        "version",
        "version-group",
        "pokemon",
        "pal-park-area"
      ].freeze

      SMOKE_PATHS = [
        "/api/v2/",
        "/api/v2/pokemon/?limit=5&offset=0",
        "/api/v2/pokemon/1/",
        "/api/v2/ability/1/",
        "/api/v2/move/1/",
        "/api/v2/item/1/",
        "/api/v2/pokemon-species/1/",
        "/api/v2/pokemon/1/encounters"
      ].freeze
      CORE_SLUGS = %w[pokemon ability move item pokemon-species type generation version-group location].freeze
      FULL_PATHS = begin
        resource_paths = RESOURCE_SLUGS.flat_map do |slug|
          [
            "/api/v2/#{slug}/?limit=5&offset=0",
            "/api/v2/#{slug}/1/"
          ]
        end

        [ROOT_PATH, *resource_paths, "/api/v2/pokemon/1/encounters"].freeze
      end
      CORE_PATHS = begin
        resource_paths = CORE_SLUGS.flat_map do |slug|
          [
            "/api/v2/#{slug}/?limit=5&offset=0",
            "/api/v2/#{slug}/1/"
          ]
        end

        [ROOT_PATH, *resource_paths, "/api/v2/pokemon/1/encounters"].freeze
      end

      PATH_PROFILES = {
        PROFILE_SMOKE => SMOKE_PATHS,
        PROFILE_CORE => CORE_PATHS,
        PROFILE_FULL => FULL_PATHS
      }.freeze
      DEFAULT_PROFILE = PROFILE_SMOKE
      DEFAULT_PATHS = PATH_PROFILES.fetch(DEFAULT_PROFILE).freeze

      def initialize(
        rails_base_url:,
        source_base_url:,
        paths: DEFAULT_PATHS,
        max_diffs: 20,
        open_timeout: 5,
        read_timeout: 20,
        max_redirects: 5
      )
        @rails_base_url = rails_base_url
        @source_base_url = source_base_url
        @paths = self.class.normalize_paths(paths)
        @max_diffs = max_diffs
        @open_timeout = open_timeout
        @read_timeout = read_timeout
        @max_redirects = max_redirects
      end

      class << self
        def paths_for(profile: DEFAULT_PROFILE)
          profile_name = normalize_profile(profile)
          PATH_PROFILES.fetch(profile_name)
        end

        def resolve_paths(paths: nil, profile: DEFAULT_PROFILE)
          return normalize_paths(paths) if paths

          paths_for(profile: profile)
        end

        def normalize_profile(profile)
          candidate = profile.to_s.strip.downcase
          return DEFAULT_PROFILE if candidate.empty?
          return candidate if VALID_PROFILES.include?(candidate)

          DEFAULT_PROFILE
        end

        def normalize_paths(paths)
          Array(paths).map { |path| normalize_path(path) }.uniq
        end

        def endpoint_group(path)
          normalized = normalize_path(path)
          return ROOT_PATH if normalized == ROOT_PATH

          segments = normalized.split("?").first.split("/").reject(&:empty?)
          return ROOT_PATH if segments.size < 3

          "/#{segments[0]}/#{segments[1]}/#{segments[2]}"
        end

        private

        def normalize_path(path)
          normalized = path.to_s.strip
          normalized = "/#{normalized}" unless normalized.start_with?("/")
          normalized = "#{normalized}/" if normalized == "/api/v2"
          normalized
        end
      end

      def run
        failures = []
        passes = 0

        @paths.each do |path|
          result = compare_path(path)
          if result[:ok]
            passes += 1
          else
            failures << result
          end
        end

        {
          total: @paths.size,
          passes: passes,
          failures: failures
        }
      end

      private

      def compare_path(path)
        rails_response = fetch_json(@rails_base_url, path)
        source_response = fetch_json(@source_base_url, path)

        if rails_response[:status] != source_response[:status]
          return {
            path: path,
            ok: false,
            reason: "status_mismatch",
            rails_status: rails_response[:status],
            source_status: source_response[:status],
            rails_error: rails_response[:error],
            source_error: source_response[:error]
          }
        end

        if rails_response[:json].nil? || source_response[:json].nil?
          return {
            path: path,
            ok: false,
            reason: "non_json_response",
            rails_status: rails_response[:status],
            source_status: source_response[:status]
          }
        end

        rails_json = normalize_json(rails_response[:json], @rails_base_url)
        source_json = normalize_json(source_response[:json], @source_base_url)
        diffs = compare_values(source_json, rails_json)

        return { path: path, ok: true } if diffs.empty?

        {
          path: path,
          ok: false,
          reason: "json_diff",
          diff_count: diffs.size,
          diffs: diffs.first(@max_diffs)
        }
      end

      def fetch_json(base_url, path)
        uri = URI.join(base_url, path)
        response = fetch_response(uri, redirects_left: @max_redirects)

        parsed_json = parse_json(response.body)

        {
          status: response.code.to_i,
          json: parsed_json
        }
      rescue StandardError => e
        {
          status: 0,
          json: nil,
          error: e.message
        }
      end

      def fetch_response(uri, redirects_left:)
        response = Net::HTTP.start(
          uri.host,
          uri.port,
          use_ssl: uri.scheme == "https",
          open_timeout: @open_timeout,
          read_timeout: @read_timeout
        ) do |http|
          request = Net::HTTP::Get.new(uri)
          request["Accept"] = "application/json"
          http.request(request)
        end

        return response unless response.is_a?(Net::HTTPRedirection)
        raise "Too many redirects for #{uri}" if redirects_left <= 0
        raise "Redirect without location for #{uri}" if response["location"].to_s.strip.empty?

        next_uri = URI.join(uri.to_s, response["location"])
        fetch_response(next_uri, redirects_left: redirects_left - 1)
      end

      def parse_json(body)
        JSON.parse(body)
      rescue JSON::ParserError
        nil
      end

      def normalize_json(value, base_url)
        case value
        when Hash
          value.transform_values { |v| normalize_json(v, base_url) }
        when Array
          value.map { |v| normalize_json(v, base_url) }
        when String
          normalize_url_string(value, base_url)
        else
          value
        end
      end

      def normalize_url_string(value, base_url)
        normalized = value.gsub(base_url.sub(%r{/+\z}, ""), "__BASE_URL__")
        normalized.gsub(%r{/\?}, "?")
      end

      def compare_values(expected, actual, path = "$", diffs = [])
        if expected.class != actual.class
          diffs << "#{path}: type mismatch expected=#{expected.class} actual=#{actual.class}"
          return diffs
        end

        case expected
        when Hash
          expected_keys = expected.keys.sort
          actual_keys = actual.keys.sort
          if expected_keys != actual_keys
            diffs << "#{path}: keys mismatch expected=#{expected_keys} actual=#{actual_keys}"
            return diffs
          end

          expected.each do |key, expected_value|
            compare_values(expected_value, actual[key], "#{path}.#{key}", diffs)
          end
        when Array
          if expected.size != actual.size
            diffs << "#{path}: length mismatch expected=#{expected.size} actual=#{actual.size}"
            return diffs
          end

          expected.each_with_index do |expected_item, index|
            compare_values(expected_item, actual[index], "#{path}[#{index}]", diffs)
          end
        else
          diffs << "#{path}: expected=#{expected.inspect} actual=#{actual.inspect}" unless expected == actual
        end

        diffs
      end
    end
  end
end
