require "test_helper"
require "fileutils"

class Pokeapi::Importers::PokeathlonStatImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "pokeathlon_stats.csv")

      File.write(csv_path, <<~CSV)
        id,identifier
        1,speed
        2,power
      CSV

      PokePokeathlonStat.delete_all

      importer = Pokeapi::Importers::PokeathlonStatImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokePokeathlonStat.count
      assert_equal "speed", PokePokeathlonStat.find(1).name

      File.write(csv_path, <<~CSV)
        id,identifier
        1,speed-updated
        3,skill
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokePokeathlonStat.count
      assert_equal "speed-updated", PokePokeathlonStat.find(1).name
      assert_equal "skill", PokePokeathlonStat.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokePokeathlonStat.find(2) }
    end
  end
end
