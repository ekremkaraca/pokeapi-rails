require "test_helper"
require "fileutils"

class Pokeapi::Importers::LocationAreaImporterTest < ActiveSupport::TestCase
  test "imports rows from csv, derives names, and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)

      locations_path = File.join(csv_dir, "locations.csv")
      File.write(locations_path, <<~CSV)
        id,region_id,identifier
        1,4,canalave-city
        6,4,oreburgh-mine
      CSV

      location_areas_path = File.join(csv_dir, "location_areas.csv")
      File.write(location_areas_path, <<~CSV)
        id,location_id,game_index,identifier
        1,1,1,
        6,6,6,1f
      CSV

      PokeLocation.delete_all
      PokeLocationArea.delete_all
      Pokeapi::Importers::LocationImporter.new(source_root: dir).run!

      importer = Pokeapi::Importers::LocationAreaImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeLocationArea.count
      assert_equal "canalave-city-area", PokeLocationArea.find(1).name
      assert_equal "oreburgh-mine-1f", PokeLocationArea.find(6).name

      File.write(location_areas_path, <<~CSV)
        id,location_id,game_index,identifier
        1,1,7,b1f
        7,6,7,b1f
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeLocationArea.count
      assert_equal "canalave-city-b1f", PokeLocationArea.find(1).name
      assert_equal 7, PokeLocationArea.find(1).game_index
      assert_equal "oreburgh-mine-b1f", PokeLocationArea.find(7).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeLocationArea.find(6) }
    end
  end
end
