require "yaml"

module Pokeapi
  module Contract
    class OpenapiValidator
      HTTP_METHODS = %w[get post put patch delete options head trace].freeze

      def initialize(path:)
        @path = path
      end

      def validate
        raise ArgumentError, "OpenAPI file not found: #{path}" unless File.exist?(path)

        data = YAML.safe_load(File.read(path), aliases: true)
        raise ArgumentError, "OpenAPI root must be a mapping/object" unless data.is_a?(Hash)

        validate_required_root_keys!(data)
        validate_paths!(data.fetch("paths"))
        true
      end

      private

      attr_reader :path

      def validate_required_root_keys!(data)
        raise ArgumentError, "Missing required key: openapi" if blank?(data["openapi"])
        raise ArgumentError, "Missing required key: info" unless data["info"].is_a?(Hash)
        raise ArgumentError, "Missing required key: info.title" if blank?(data.dig("info", "title"))
        raise ArgumentError, "Missing required key: info.version" if blank?(data.dig("info", "version"))
        raise ArgumentError, "Missing required key: paths" unless data["paths"].is_a?(Hash)
      end

      def validate_paths!(paths)
        raise ArgumentError, "OpenAPI paths must not be empty" if paths.empty?

        paths.each do |path_key, operations|
          path_string = path_key.to_s
          unless path_string.start_with?("/api/v3")
            raise ArgumentError, "Invalid path '#{path_string}': only /api/v3 paths are allowed in v3 OpenAPI"
          end
          raise ArgumentError, "Path '#{path_string}' must map to an object" unless operations.is_a?(Hash)

          operations.each do |method_name, operation|
            method = method_name.to_s.downcase
            next if method.start_with?("x-")
            next if method == "parameters"
            unless HTTP_METHODS.include?(method)
              raise ArgumentError, "Path '#{path_string}' has unsupported method '#{method_name}'"
            end
            raise ArgumentError, "Operation '#{method.upcase} #{path_string}' must be an object" unless operation.is_a?(Hash)
            raise ArgumentError, "Operation '#{method.upcase} #{path_string}' is missing responses" unless operation["responses"].is_a?(Hash)
          end
        end
      end

      def blank?(value)
        value.to_s.strip.empty?
      end
    end
  end
end
