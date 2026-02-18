require Rails.root.join("lib/pokeapi/contract/openapi_drift")
require Rails.root.join("lib/pokeapi/contract/report_formatter")
require Rails.root.join("lib/pokeapi/contract/openapi_validator")

namespace :pokeapi do
  namespace :contract do
    desc "Compare source OpenAPI paths/methods against Rails /api/v2 routes"
    task drift: :environment do
      source_openapi_path = ENV.fetch("SOURCE_OPENAPI_PATH", File.expand_path("../pokeapi/openapi.yml", Rails.root))
      max_items = ENV.fetch("MAX_ITEMS", "200").to_i
      output_format = ENV.fetch("OUTPUT_FORMAT", "text").to_s.strip.downcase

      unless File.exist?(source_openapi_path)
        raise "SOURCE_OPENAPI_PATH not found: #{source_openapi_path}"
      end

      result = Pokeapi::Contract::OpenapiDrift.new(source_openapi_path: source_openapi_path).run

      formatter = Pokeapi::Contract::ReportFormatter.new(result: result, max_items: max_items)

      case output_format
      when "text"
        puts formatter.text
      when "json"
        puts formatter.json
      else
        raise "Unsupported OUTPUT_FORMAT=#{output_format.inspect} (expected: text or json)"
      end

      raise "Contract drift detected" unless result[:matches]
    end

    desc "Validate /api/v3 OpenAPI skeleton contract file"
    task :validate_v3_openapi do
      openapi_path = ENV.fetch("V3_OPENAPI_PATH", Rails.root.join("docs/openapi-v3.yml").to_s)
      validator = Pokeapi::Contract::OpenapiValidator.new(path: openapi_path)
      validator.validate
      puts "Validated v3 OpenAPI: #{openapi_path}"
    end
  end
end
