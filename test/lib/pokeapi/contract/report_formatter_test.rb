require "test_helper"
require Rails.root.join("lib/pokeapi/contract/report_formatter")

class Pokeapi::Contract::ReportFormatterTest < ActiveSupport::TestCase
  test "json output includes full mismatch lists and summary counts" do
    result = {
      source_openapi_path: "/tmp/openapi.yml",
      source_count: 97,
      rails_count: 98,
      matches: false,
      missing_in_rails: ["GET /api/v2/a"],
      extra_in_rails: ["GET /api/v2/b"]
    }

    formatter = Pokeapi::Contract::ReportFormatter.new(result: result, max_items: 200)
    payload = JSON.parse(formatter.json)

    assert_equal "pokeapi:contract:drift", payload["task"]
    assert_equal false, payload["matches"]
    assert_equal 1, payload["missing_count"]
    assert_equal 1, payload["extra_count"]
    assert_equal ["GET /api/v2/a"], payload["missing_in_rails"]
    assert_equal ["GET /api/v2/b"], payload["extra_in_rails"]
  end
end
