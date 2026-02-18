if defined?(Oj)
  Oj.default_options = {
    mode: :rails,
    use_to_json: true,
    time_format: :xmlschema
  }

  Oj.optimize_rails
end
