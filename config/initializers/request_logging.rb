return if ENV["SIMPLE_REQUEST_LOGS"] == "0"

require Rails.root.join("lib/pokeapi/logging/request_event")

Rails.application.config.after_initialize do
  # Replace noisy multi-line controller/view request logs with one compact JSON event.
  ActionController::LogSubscriber.detach_from :action_controller if defined?(ActionController::LogSubscriber)
  ActionView::LogSubscriber.detach_from :action_view if defined?(ActionView::LogSubscriber)
end

slow_request_ms = ENV.fetch("SIMPLE_REQUEST_SLOW_MS", "500").to_f
suppress_404_noise = ENV.fetch("SIMPLE_REQUEST_SUPPRESS_404_NOISE", "1") == "1"
suppressed_404_path_pattern = %r{\A/(?:assets/|\.git(?:/|\z)|.*\.php\z|server-status\z|server-info\z|graphql\z)}

ActiveSupport::Notifications.subscribe("process_action.action_controller") do |_name, started_at, finished_at, _id, payload|
  next if payload[:path] == "/up"

  event = Pokeapi::Logging::RequestEvent.build(
    payload: payload,
    started_at: started_at,
    finished_at: finished_at
  )
  if suppress_404_noise && event[:status].to_i == 404 && event[:controller] == "ErrorsController" &&
      suppressed_404_path_pattern.match?(event[:path].to_s)
    next
  end

  log_method = event[:duration_ms].to_f >= slow_request_ms ? :warn : :info
  Rails.logger.public_send(log_method, event.to_json)
end
