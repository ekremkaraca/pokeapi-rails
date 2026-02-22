module SqlCaptureHelpers
  def capture_select_queries
    queries = []
    callback = lambda do |_name, _start, _finish, _id, payload|
      sql = payload[:sql].to_s
      next if payload[:name] == "SCHEMA"
      next unless sql.start_with?("SELECT")

      queries << sql
    end

    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") { yield }
    queries
  end

  def capture_select_query_count(&block)
    capture_select_queries(&block).size
  end
end
