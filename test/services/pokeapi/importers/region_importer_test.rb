require "test_helper"
require "fileutils"

class Pokeapi::Importers::RegionImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "regions.csv")

      File.write(csv_path, <<~CSV)
        id,identifier
        1,kanto
        2,johto
      CSV

      PokeRegion.delete_all

      importer = Pokeapi::Importers::RegionImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeRegion.count
      assert_equal "kanto", PokeRegion.find(1).name

      File.write(csv_path, <<~CSV)
        id,identifier
        1,kanto-updated
        3,hoenn
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeRegion.count
      assert_equal "kanto-updated", PokeRegion.find(1).name
      assert_equal "hoenn", PokeRegion.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeRegion.find(2) }
    end
  end
end
