OasRails.configure do |config|
  config.info.title = "PokeAPI Rails"
  config.info.version = "v3"
  config.info.summary = "PokeAPI v3 API documentation"
  config.info.description = <<~MARKDOWN
    OpenAPI documentation for the `/api/v3` surface served by this Rails app.

    The v2 API remains available for compatibility, while v3 is the normalized API surface under active migration.
  MARKDOWN

  config.servers = [
    { url: "http://localhost:3000", description: "Local" }
  ]

  # Keep generated docs focused on the v3 namespace.
  config.api_path = "/api/v3"

  # Group operations by top-level namespace (v3 resources).
  config.default_tags_from = :namespace

  # The API is public; do not force auth in generated docs by default.
  config.authenticate_all_routes_by_default = false
end
