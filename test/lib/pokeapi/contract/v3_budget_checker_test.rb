require "test_helper"
require Rails.root.join("lib/pokeapi/contract/v3_budget_checker")

class Pokeapi::Contract::V3BudgetCheckerTest < ActiveSupport::TestCase
  FakeResponse = Struct.new(:status, :headers, keyword_init: true)

  class FakeSession
    attr_reader :response

    def initialize(responses_by_path)
      @responses_by_path = responses_by_path
    end

    def get(path)
      @response = @responses_by_path.fetch(path)
    end
  end

  test "passes when all scenarios are within budget" do
    scenarios = [ { name: "pokemon_list", path: "/api/v3/pokemon", kind: :list, include: false } ]
    budgets = { [ :list, false ] => { query_max: 8, response_ms_max: 150.0 } }
    session = FakeSession.new(
      "/api/v3/pokemon" => FakeResponse.new(status: 200, headers: { "X-Query-Count" => "5", "X-Response-Time-Ms" => "40.12" })
    )

    result = Pokeapi::Contract::V3BudgetChecker.new(session: session, scenarios: scenarios, budgets: budgets).run

    assert_equal true, result[:passed]
    assert_equal true, result[:scenarios].first[:passed]
    assert_equal [], result[:scenarios].first[:breaches]
  end

  test "fails when query count exceeds budget" do
    scenarios = [ { name: "pokemon_list", path: "/api/v3/pokemon", kind: :list, include: false } ]
    budgets = { [ :list, false ] => { query_max: 8, response_ms_max: 150.0 } }
    session = FakeSession.new(
      "/api/v3/pokemon" => FakeResponse.new(status: 200, headers: { "X-Query-Count" => "9", "X-Response-Time-Ms" => "40.12" })
    )

    result = Pokeapi::Contract::V3BudgetChecker.new(session: session, scenarios: scenarios, budgets: budgets).run

    assert_equal false, result[:passed]
    assert_equal false, result[:scenarios].first[:passed]
    assert_includes result[:scenarios].first[:breaches].join(" "), "query_count_exceeded"
  end

  test "fails when observability headers are missing" do
    scenarios = [ { name: "pokemon_list", path: "/api/v3/pokemon", kind: :list, include: false } ]
    budgets = { [ :list, false ] => { query_max: 8, response_ms_max: 150.0 } }
    session = FakeSession.new(
      "/api/v3/pokemon" => FakeResponse.new(status: 200, headers: {})
    )

    result = Pokeapi::Contract::V3BudgetChecker.new(session: session, scenarios: scenarios, budgets: budgets).run

    assert_equal false, result[:passed]
    assert_equal false, result[:scenarios].first[:passed]
    assert_includes result[:scenarios].first[:breaches], "missing_or_invalid_header:X-Query-Count"
    assert_includes result[:scenarios].first[:breaches], "missing_or_invalid_header:X-Response-Time-Ms"
  end
end
