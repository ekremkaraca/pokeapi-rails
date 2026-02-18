require "test_helper"
require "fileutils"

class Pokeapi::Importers::ContestTypeImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "contest_types.csv")

      File.write(csv_path, <<~CSV)
        id,identifier
        1,cool
        2,beauty
      CSV

      PokeContestType.delete_all

      importer = Pokeapi::Importers::ContestTypeImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeContestType.count
      assert_equal "cool", PokeContestType.find(1).name

      File.write(csv_path, <<~CSV)
        id,identifier
        1,cool-updated
        3,cute
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeContestType.count
      assert_equal "cool-updated", PokeContestType.find(1).name
      assert_equal "cute", PokeContestType.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeContestType.find(2) }
    end
  end
end
