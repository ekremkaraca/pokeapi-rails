require "test_helper"

class Pokeapi::Parity::ResponseDiffTest < ActiveSupport::TestCase
  test "resolves profile to expected path set" do
    smoke = Pokeapi::Parity::ResponseDiff.resolve_paths(profile: "smoke")
    core = Pokeapi::Parity::ResponseDiff.resolve_paths(profile: "core")
    full = Pokeapi::Parity::ResponseDiff.resolve_paths(profile: "full")

    assert_equal Pokeapi::Parity::ResponseDiff::SMOKE_PATHS, smoke
    assert_equal Pokeapi::Parity::ResponseDiff::CORE_PATHS, core
    assert_equal Pokeapi::Parity::ResponseDiff::FULL_PATHS, full
    assert_operator full.size, :>, core.size
    assert_operator core.size, :>, smoke.size
  end

  test "falls back to default profile for unknown profile" do
    paths = Pokeapi::Parity::ResponseDiff.resolve_paths(profile: "unknown-profile")
    assert_equal Pokeapi::Parity::ResponseDiff::SMOKE_PATHS, paths
  end

  test "normalizes explicit paths and preserves uniqueness" do
    paths = Pokeapi::Parity::ResponseDiff.resolve_paths(
      paths: [ "api/v2/pokemon/1/", " /api/v2/pokemon/1/ ", "/api/v2", "/api/v2/ability/1/" ]
    )

    assert_equal [ "/api/v2/pokemon/1/", "/api/v2/", "/api/v2/ability/1/" ], paths
  end

  test "normalizes base urls and produces no diff for equivalent payloads" do
    engine = Pokeapi::Parity::ResponseDiff.new(
      rails_base_url: "http://localhost:3000",
      source_base_url: "http://localhost:8000",
      paths: []
    )

    source = {
      "name" => "bulbasaur",
      "url" => "http://localhost:8000/api/v2/pokemon/1/"
    }
    rails = {
      "name" => "bulbasaur",
      "url" => "http://localhost:3000/api/v2/pokemon/1/"
    }

    source_normalized = engine.send(:normalize_json, source, "http://localhost:8000")
    rails_normalized = engine.send(:normalize_json, rails, "http://localhost:3000")
    diffs = engine.send(:compare_values, source_normalized, rails_normalized)

    assert_equal [], diffs
  end

  test "reports value differences with json path" do
    engine = Pokeapi::Parity::ResponseDiff.new(
      rails_base_url: "http://localhost:3000",
      source_base_url: "http://localhost:8000",
      paths: []
    )

    expected = { "id" => 1, "name" => "bulbasaur" }
    actual = { "id" => 1, "name" => "ivysaur" }
    diffs = engine.send(:compare_values, expected, actual)

    assert_equal 1, diffs.size
    assert_match(/\$\.name:/, diffs.first)
  end

  test "treats optional slash before query as equivalent for urls" do
    engine = Pokeapi::Parity::ResponseDiff.new(
      rails_base_url: "http://localhost:3000",
      source_base_url: "http://localhost:8000",
      paths: []
    )

    source = { "next" => "http://localhost:8000/api/v2/ability/?limit=5&offset=5" }
    rails = { "next" => "http://localhost:3000/api/v2/ability?limit=5&offset=5" }

    source_normalized = engine.send(:normalize_json, source, "http://localhost:8000")
    rails_normalized = engine.send(:normalize_json, rails, "http://localhost:3000")
    diffs = engine.send(:compare_values, source_normalized, rails_normalized)

    assert_equal [], diffs
  end

  test "fetch_json returns structured error for expected fetch failures" do
    engine = Pokeapi::Parity::ResponseDiff.new(
      rails_base_url: "http://localhost:3000",
      source_base_url: "http://localhost:8000",
      paths: []
    )

    # Override only this test instance to simulate a transport timeout.
    engine.define_singleton_method(:fetch_response) do |_uri, redirects_left:|
      raise Timeout::Error, "timed out"
    end

    response = engine.send(:fetch_json, "http://localhost:3000", "/api/v2/pokemon/1/")
    assert_equal 0, response[:status]
    assert_nil response[:json]
    assert_match(/timed out/, response[:error])
  end

  test "fetch_json re-raises unexpected errors" do
    engine = Pokeapi::Parity::ResponseDiff.new(
      rails_base_url: "http://localhost:3000",
      source_base_url: "http://localhost:8000",
      paths: []
    )

    # Override only this test instance so unexpected errors still bubble up.
    engine.define_singleton_method(:fetch_response) do |_uri, redirects_left:|
      raise NoMethodError, "unexpected"
    end

    assert_raises(NoMethodError) do
      engine.send(:fetch_json, "http://localhost:3000", "/api/v2/pokemon/1/")
    end
  end
end
