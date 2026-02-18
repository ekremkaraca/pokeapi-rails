require "test_helper"
require "fileutils"

class Pokeapi::Importers::LocationImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "locations.csv")

      File.write(csv_path, <<~CSV)
        id,region_id,identifier
        1,4,canalave-city
        2,4,eterna-city
      CSV

      PokeLocation.delete_all

      importer = Pokeapi::Importers::LocationImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeLocation.count
      assert_equal "canalave-city", PokeLocation.find(1).name
      assert_equal 4, PokeLocation.find(1).region_id

      File.write(csv_path, <<~CSV)
        id,region_id,identifier
        1,5,canalave-city-updated
        3,4,pastoria-city
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeLocation.count
      assert_equal "canalave-city-updated", PokeLocation.find(1).name
      assert_equal 5, PokeLocation.find(1).region_id
      assert_equal "pastoria-city", PokeLocation.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeLocation.find(2) }
    end
  end
end
