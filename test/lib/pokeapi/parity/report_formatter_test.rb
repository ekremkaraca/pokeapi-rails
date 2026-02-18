require "test_helper"
require Rails.root.join("lib/pokeapi/parity/report_formatter")

class Pokeapi::Parity::ReportFormatterTest < ActiveSupport::TestCase
  test "json output includes summary metadata and grouped failure counts" do
    result = {
      total: 3,
      passes: 2,
      failures: [
        { path: "/api/v2/pokemon/1/", reason: "json_diff", diff_count: 1, diffs: ["$.name: expected=\"a\" actual=\"b\""] }
      ]
    }

    formatter = Pokeapi::Parity::ReportFormatter.new(
      result: result,
      profile: "core",
      max_diffs: 20,
      rails_base_url: "http://localhost:3000",
      source_base_url: "http://localhost:8000"
    )

    payload = JSON.parse(formatter.json)
    assert_equal "pokeapi:parity:diff", payload["task"]
    assert_equal "core", payload["profile"]
    assert_equal 3, payload["total"]
    assert_equal 2, payload["passes"]
    assert_equal 1, payload["failure_count"]
    assert_equal false, payload["matches"]
    assert_equal({ "/api/v2/pokemon" => 1 }, payload["failures_by_endpoint"])
  end
end
