require "test_helper"
require "fileutils"

class Pokeapi::Importers::GrowthRateImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "growth_rates.csv")

      File.write(csv_path, <<~CSV)
        id,identifier,formula
        1,slow,\\frac{5x^3}{4}
        2,medium,x^3
      CSV

      PokeGrowthRate.delete_all

      importer = Pokeapi::Importers::GrowthRateImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeGrowthRate.count
      assert_equal "\\frac{5x^3}{4}", PokeGrowthRate.find(1).formula

      File.write(csv_path, <<~CSV)
        id,identifier,formula
        1,slow-updated,updated-formula
        3,fast,\\frac{4x^3}{5}
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeGrowthRate.count
      assert_equal "slow-updated", PokeGrowthRate.find(1).name
      assert_equal "updated-formula", PokeGrowthRate.find(1).formula
      assert_equal "fast", PokeGrowthRate.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeGrowthRate.find(2) }
    end
  end
end
