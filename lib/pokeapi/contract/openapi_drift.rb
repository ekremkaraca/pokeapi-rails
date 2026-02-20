require "set"
require "yaml"

module Pokeapi
  module Contract
    class OpenapiDrift
      HTTP_METHODS = %w[get post put patch delete options head].freeze
      DEFAULT_API_PREFIX = "/api/v2".freeze
      DEFAULT_IGNORED_PATHS = ["/api/v2"].freeze

      def initialize(source_openapi_path:, rails_routes: Rails.application.routes.routes, api_prefix: DEFAULT_API_PREFIX, ignored_paths: nil)
        @source_openapi_path = source_openapi_path
        @rails_routes = rails_routes
        @api_prefix = api_prefix
        @ignored_paths = Array(ignored_paths.nil? ? default_ignored_paths_for(api_prefix) : ignored_paths)
      end

      def run
        source_operations = openapi_operations
        rails_operations = rails_route_operations

        missing_in_rails = (source_operations - rails_operations).to_a.sort
        extra_in_rails = (rails_operations - source_operations).to_a.sort

        {
          source_openapi_path: source_openapi_path,
          source_count: source_operations.size,
          rails_count: rails_operations.size,
          missing_in_rails: missing_in_rails,
          extra_in_rails: extra_in_rails,
          matches: missing_in_rails.empty? && extra_in_rails.empty?
        }
      end

      private

      attr_reader :source_openapi_path, :rails_routes, :api_prefix, :ignored_paths

      def openapi_operations
        data = YAML.safe_load(File.read(source_openapi_path), aliases: true) || {}
        unless data.is_a?(Hash)
          raise ArgumentError, "invalid OpenAPI document root in #{source_openapi_path} (expected mapping/object)"
        end

        paths = data.fetch("paths", {})
        unless paths.is_a?(Hash)
          raise ArgumentError, "invalid OpenAPI paths section in #{source_openapi_path} (expected mapping/object)"
        end

        operations = Set.new

        paths.each do |raw_path, methods|
          path = normalize_openapi_path(raw_path)
          next unless path
          next unless methods.is_a?(Hash)

          methods.each do |raw_method, _schema|
            method = raw_method.to_s.downcase
            next unless HTTP_METHODS.include?(method)

            operations << operation_key(method, path)
          end
        end

        operations
      end

      def rails_route_operations
        operations = Set.new

        rails_routes.each do |route|
          path = normalize_rails_path(route.path.spec.to_s)
          next unless path
          next if ignored_paths.include?(path)

          parse_route_verbs(route.verb.to_s).each do |verb|
            operations << operation_key(verb, path)
          end
        end

        operations
      end

      def parse_route_verbs(raw_verb)
        verb = raw_verb.to_s.upcase
        return [] if verb.empty?

        HTTP_METHODS.map(&:upcase).select { |candidate| verb.include?(candidate) }
      end

      def normalize_rails_path(raw_path)
        path = raw_path.to_s.sub(/\(\.:format\)\z/, "")
        path = path.sub(/\(\/\)\z/, "")
        return nil unless path.start_with?(api_prefix)

        path = path.gsub(/:([a-zA-Z_]\w*)/, '{\1}')
        path = normalize_path_parameters(path)
        canonical_path(path)
      end

      def normalize_openapi_path(raw_path)
        path = raw_path.to_s
        return nil unless path.start_with?(api_prefix)

        path = normalize_path_parameters(path)
        canonical_path(path)
      end

      def canonical_path(path)
        canonical = path.sub(%r{/+\z}, "")
        canonical.empty? ? "/" : canonical
      end

      def normalize_path_parameters(path)
        path.gsub(/\{[^}]+\}/, "{}")
      end

      def operation_key(method, path)
        "#{method.to_s.upcase} #{path}"
      end

      def default_ignored_paths_for(prefix)
        prefix == DEFAULT_API_PREFIX ? DEFAULT_IGNORED_PATHS : []
      end
    end
  end
end
