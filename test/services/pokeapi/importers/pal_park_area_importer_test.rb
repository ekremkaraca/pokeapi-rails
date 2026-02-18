require "test_helper"
require "fileutils"

class Pokeapi::Importers::PalParkAreaImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "pal_park_areas.csv")

      File.write(csv_path, <<~CSV)
        id,identifier
        1,forest
        2,field
      CSV

      PokePalParkArea.delete_all

      importer = Pokeapi::Importers::PalParkAreaImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokePalParkArea.count
      assert_equal "forest", PokePalParkArea.find(1).name

      File.write(csv_path, <<~CSV)
        id,identifier
        1,forest-updated
        3,mountain
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokePalParkArea.count
      assert_equal "forest-updated", PokePalParkArea.find(1).name
      assert_equal "mountain", PokePalParkArea.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokePalParkArea.find(2) }
    end
  end
end
