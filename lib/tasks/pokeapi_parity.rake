require Rails.root.join("lib/pokeapi/parity/response_diff")
require Rails.root.join("lib/pokeapi/parity/report_formatter")

namespace :pokeapi do
  namespace :parity do
    desc "Compare sampled /api/v2 responses between Rails and source API"
    task diff: :environment do
      rails_base_url = ENV.fetch("RAILS_BASE_URL", "http://localhost:3000")
      source_base_url = ENV.fetch("SOURCE_BASE_URL", "http://localhost:8000")
      max_diffs = ENV.fetch("MAX_DIFFS", "20").to_i
      profile = ENV.fetch("PATH_PROFILE", Pokeapi::Parity::ResponseDiff::DEFAULT_PROFILE)
      output_format = ENV.fetch("OUTPUT_FORMAT", "text").to_s.strip.downcase
      explicit_paths = ENV["PATHS"]&.split(",")
      paths = Pokeapi::Parity::ResponseDiff.resolve_paths(paths: explicit_paths, profile: profile)
      normalized_profile = Pokeapi::Parity::ResponseDiff.normalize_profile(profile)

      result = Pokeapi::Parity::ResponseDiff.new(
        rails_base_url: rails_base_url,
        source_base_url: source_base_url,
        paths: paths,
        max_diffs: max_diffs
      ).run

      formatter = Pokeapi::Parity::ReportFormatter.new(
        result: result,
        profile: normalized_profile,
        max_diffs: max_diffs,
        rails_base_url: rails_base_url,
        source_base_url: source_base_url
      )

      case output_format
      when "text"
        puts formatter.text
      when "json"
        puts formatter.json
      else
        raise "Unsupported OUTPUT_FORMAT=#{output_format.inspect} (expected: text or json)"
      end

      raise "Parity diff failed" if result[:failures].any?
    end
  end
end
