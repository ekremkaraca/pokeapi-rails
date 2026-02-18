require "test_helper"
require "fileutils"

class Pokeapi::Importers::EggGroupImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "egg_groups.csv")

      File.write(csv_path, <<~CSV)
        id,identifier
        1,monster
        2,water-1
      CSV

      PokeEggGroup.delete_all

      importer = Pokeapi::Importers::EggGroupImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeEggGroup.count
      assert_equal "monster", PokeEggGroup.find(1).name

      File.write(csv_path, <<~CSV)
        id,identifier
        1,monster-updated
        3,bug
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeEggGroup.count
      assert_equal "monster-updated", PokeEggGroup.find(1).name
      assert_equal "bug", PokeEggGroup.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeEggGroup.find(2) }
    end
  end
end
