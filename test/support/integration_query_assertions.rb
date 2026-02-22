module IntegrationQueryAssertions
  def assert_not_found_error_envelope(payload)
    assert_equal "not_found", payload.dig("error", "code")
    assert_equal "Resource not found", payload.dig("error", "message")
    assert_kind_of Hash, payload.dig("error", "details")
    assert_kind_of String, payload.dig("error", "request_id")
  end

  def assert_invalid_query_error(payload, param:, invalid_values:)
    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal param, payload.dig("error", "details", "param")
    assert_equal invalid_values, payload.dig("error", "details", "invalid_values")
  end

  def assert_observability_headers
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
  end

  def assert_query_count_at_most(max)
    header = response.headers["X-Query-Count"]
    assert_match(/\A\d+\z/, header)
    assert_operator header.to_i, :<=, max
  end
end
