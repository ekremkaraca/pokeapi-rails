require "test_helper"
require "fileutils"

class Pokeapi::Importers::EncounterMethodImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "encounter_methods.csv")

      File.write(csv_path, <<~CSV)
        id,identifier,order
        1,walk,1
        2,old-rod,10
      CSV

      PokeEncounterMethod.delete_all

      importer = Pokeapi::Importers::EncounterMethodImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeEncounterMethod.count
      assert_equal "walk", PokeEncounterMethod.find(1).name
      assert_equal 1, PokeEncounterMethod.find(1).sort_order

      File.write(csv_path, <<~CSV)
        id,identifier,order
        1,walk-updated,2
        3,good-rod,11
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeEncounterMethod.count
      assert_equal "walk-updated", PokeEncounterMethod.find(1).name
      assert_equal 2, PokeEncounterMethod.find(1).sort_order
      assert_equal "good-rod", PokeEncounterMethod.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeEncounterMethod.find(2) }
    end
  end
end
