module Api
  module ObservabilityHeaders
    extend ActiveSupport::Concern

    private

    def set_observability_headers
      query_count = 0
      started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      callback = lambda do |_name, _start, _finish, _id, payload|
        next if payload[:cached]
        next if payload[:name] == "SCHEMA"

        sql = payload[:sql].to_s
        next if sql.start_with?("BEGIN", "COMMIT", "ROLLBACK", "SAVEPOINT", "RELEASE SAVEPOINT")

        query_count += 1
      end

      ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
        yield
      end
    ensure
      elapsed_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000.0).round(2)
      response.set_header("X-Query-Count", query_count.to_s)
      response.set_header("X-Response-Time-Ms", elapsed_ms.to_s)
    end
  end
end
