require "test_helper"
require "pg_query"
require "prosopite"
require "securerandom"

class GemRuntimeSmokeTest < ActiveSupport::TestCase
  test "pg_query parses and fingerprints SQL" do
    parsed = PgQuery.parse("SELECT id, name FROM contest_type WHERE id = 42")

    assert_equal 1, parsed.tree.stmts.length
    assert_match(/\A[0-9a-f]{16}\z/, PgQuery.fingerprint("SELECT 1"))
  end

  test "prosopite detects n+1 query pattern" do
    original_raise = Prosopite.raise?
    original_enabled = Prosopite.enabled?
    original_min = Prosopite.min_n_queries

    Prosopite.raise = true
    Prosopite.enabled = true
    Prosopite.min_n_queries = 2

    suffix = SecureRandom.hex(4)
    %w[cool beauty smart].each do |name|
      PokeContestType.create!(name: "#{name}-#{suffix}")
    end

    ids = PokeContestType.where("name LIKE ?", "%#{suffix}").order(:id).pluck(:id)

    runner = lambda do
      ids.each do |id|
        PokeContestType.where(id: id).first
      end
    end

    if Prosopite.scan?
      runner.call
      assert_raises(Prosopite::NPlusOneQueriesError) { Prosopite.finish }
    else
      assert_raises(Prosopite::NPlusOneQueriesError) do
        Prosopite.scan do
          runner.call
        end
      end
    end
  ensure
    Prosopite.raise = original_raise
    Prosopite.enabled = original_enabled
    Prosopite.min_n_queries = original_min
    Prosopite.finish
  end
end
