require "json"

module Pokeapi
  module Contract
    class V3BudgetChecker
      def initialize(session:, scenarios:, budgets:)
        @session = session
        @scenarios = scenarios
        @budgets = budgets
      end

      def run
        scenario_results = scenarios.map { |scenario| evaluate_scenario(scenario) }

        {
          task: "pokeapi:contract:check_v3_budgets",
          scenarios: scenario_results,
          passed: scenario_results.all? { |result| result[:passed] }
        }
      end

      private

      attr_reader :session, :scenarios, :budgets

      def evaluate_scenario(scenario)
        session.get(scenario.fetch(:path))
        response = session.response
        query_count = parse_integer_header(response.headers["X-Query-Count"])
        response_time_ms = parse_float_header(response.headers["X-Response-Time-Ms"])
        budget = budget_for(scenario)

        breaches = []
        breaches << "status=#{response.status}" unless response.status.to_i == 200
        breaches << "missing_or_invalid_header:X-Query-Count" if query_count.nil?
        breaches << "missing_or_invalid_header:X-Response-Time-Ms" if response_time_ms.nil?
        breaches << "query_count_exceeded(#{query_count} > #{budget[:query_max]})" if query_count && query_count > budget[:query_max]
        breaches << "response_time_exceeded(#{response_time_ms} > #{budget[:response_ms_max]})" if response_time_ms && response_time_ms > budget[:response_ms_max]

        {
          name: scenario.fetch(:name),
          path: scenario.fetch(:path),
          query_count: query_count,
          response_time_ms: response_time_ms,
          budget: budget,
          status: response.status.to_i,
          breaches: breaches,
          passed: breaches.empty?
        }
      end

      def budget_for(scenario)
        key = [scenario.fetch(:kind), scenario.fetch(:include)]
        budgets.fetch(key)
      end

      def parse_integer_header(value)
        raw = value.to_s.strip
        return nil unless /\A\d+\z/.match?(raw)

        raw.to_i
      end

      def parse_float_header(value)
        raw = value.to_s.strip
        return nil unless /\A\d+(\.\d+)?\z/.match?(raw)

        raw.to_f
      end
    end
  end
end
