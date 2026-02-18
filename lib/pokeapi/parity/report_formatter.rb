require "json"

module Pokeapi
  module Parity
    class ReportFormatter
      def initialize(result:, profile:, max_diffs:, rails_base_url:, source_base_url:)
        @result = result
        @profile = profile
        @max_diffs = max_diffs
        @rails_base_url = rails_base_url
        @source_base_url = source_base_url
      end

      def text
        lines = []
        lines << "Profile: #{@profile} (override with PATH_PROFILE=smoke|core|full)"
        lines << "Compared #{@result[:total]} path(s): #{@result[:passes]} passed, #{@result[:failures].size} failed"

        grouped_failures = @result[:failures].group_by { |failure| Pokeapi::Parity::ResponseDiff.endpoint_group(failure[:path]) }
        grouped_failures.sort.each do |endpoint, failures|
          lines << ""
          lines << "Endpoint: #{endpoint} (#{failures.size} failure#{failures.size == 1 ? "" : "s"})"

          failures.each do |failure|
            lines << "  Path: #{failure[:path]}"
            lines << "  Reason: #{failure[:reason]}"

            if failure[:reason] == "status_mismatch"
              lines << "  Status mismatch: rails=#{failure[:rails_status]} source=#{failure[:source_status]}"
              lines << "  Rails error: #{failure[:rails_error]}" if failure[:rails_error]
              lines << "  Source error: #{failure[:source_error]}" if failure[:source_error]
            elsif failure[:reason] == "json_diff"
              lines << "  Diff count: #{failure[:diff_count]}"
              failure[:diffs].each { |diff| lines << "    - #{diff}" }
            end

            if failure[:diff_count] && failure[:diff_count] > @max_diffs
              lines << "    ... truncated #{failure[:diff_count] - @max_diffs} additional diff(s) (MAX_DIFFS=#{@max_diffs})"
            end
          end
        end

        lines.join("\n")
      end

      def json
        JSON.pretty_generate(as_json)
      end

      def as_json
        grouped_failures = @result[:failures].group_by { |failure| Pokeapi::Parity::ResponseDiff.endpoint_group(failure[:path]) }

        {
          task: "pokeapi:parity:diff",
          profile: @profile,
          rails_base_url: @rails_base_url,
          source_base_url: @source_base_url,
          max_diffs: @max_diffs,
          total: @result[:total],
          passes: @result[:passes],
          failure_count: @result[:failures].size,
          matches: @result[:failures].empty?,
          failures: @result[:failures],
          failures_by_endpoint: grouped_failures.transform_values(&:size)
        }
      end
    end
  end
end
