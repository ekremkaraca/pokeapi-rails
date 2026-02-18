require "json"

module Pokeapi
  module Contract
    class ReportFormatter
      def initialize(result:, max_items:)
        @result = result
        @max_items = max_items
      end

      def text
        lines = []
        lines << "Source OpenAPI: #{@result[:source_openapi_path]}"
        lines << "Operations: source=#{@result[:source_count]} rails=#{@result[:rails_count]}"
        lines << "Contract drift: #{@result[:matches] ? "none" : "detected"}"

        if @result[:missing_in_rails].any?
          lines << ""
          lines << "Missing in Rails (#{@result[:missing_in_rails].size}):"
          @result[:missing_in_rails].first(@max_items).each { |operation| lines << "  - #{operation}" }
          if @result[:missing_in_rails].size > @max_items
            lines << "  ... truncated #{@result[:missing_in_rails].size - @max_items} additional item(s) (MAX_ITEMS=#{@max_items})"
          end
        end

        if @result[:extra_in_rails].any?
          lines << ""
          lines << "Extra in Rails (#{@result[:extra_in_rails].size}):"
          @result[:extra_in_rails].first(@max_items).each { |operation| lines << "  - #{operation}" }
          if @result[:extra_in_rails].size > @max_items
            lines << "  ... truncated #{@result[:extra_in_rails].size - @max_items} additional item(s) (MAX_ITEMS=#{@max_items})"
          end
        end

        lines.join("\n")
      end

      def json
        JSON.pretty_generate(as_json)
      end

      def as_json
        {
          task: "pokeapi:contract:drift",
          source_openapi_path: @result[:source_openapi_path],
          source_count: @result[:source_count],
          rails_count: @result[:rails_count],
          missing_count: @result[:missing_in_rails].size,
          extra_count: @result[:extra_in_rails].size,
          matches: @result[:matches],
          missing_in_rails: @result[:missing_in_rails],
          extra_in_rails: @result[:extra_in_rails]
        }
      end
    end
  end
end
