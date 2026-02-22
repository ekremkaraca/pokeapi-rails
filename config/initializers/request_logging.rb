return if ENV["SIMPLE_REQUEST_LOGS"] == "0"

require Rails.root.join("lib/pokeapi/logging/request_event")

# Replace noisy multi-line controller/view request logs with one compact JSON event.
ActionController::LogSubscriber.detach_from :action_controller if defined?(ActionController::LogSubscriber)
ActionView::LogSubscriber.detach_from :action_view if defined?(ActionView::LogSubscriber)

ActiveSupport::Notifications.subscribe("process_action.action_controller") do |_name, started_at, finished_at, _id, payload|
  next if payload[:path] == "/up"

  event = Pokeapi::Logging::RequestEvent.build(
    payload: payload,
    started_at: started_at,
    finished_at: finished_at
  )
  Rails.logger.info(event.to_json)
end
