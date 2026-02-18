require "test_helper"
require "fileutils"

class Pokeapi::Importers::PokedexImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "pokedexes.csv")

      File.write(csv_path, <<~CSV)
        id,region_id,identifier,is_main_series
        1,,national,1
        2,1,kanto,1
      CSV

      PokePokedex.delete_all

      importer = Pokeapi::Importers::PokedexImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokePokedex.count
      assert_equal "national", PokePokedex.find(1).name

      File.write(csv_path, <<~CSV)
        id,region_id,identifier,is_main_series
        1,,national-updated,1
        11,,conquest-gallery,0
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokePokedex.count
      assert_equal "national-updated", PokePokedex.find(1).name
      assert_equal "conquest-gallery", PokePokedex.find(11).name
      assert_equal false, PokePokedex.find(11).is_main_series
      assert_raises(ActiveRecord::RecordNotFound) { PokePokedex.find(2) }
    end
  end

  test "handles blank region_id" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "pokedexes.csv")

      File.write(csv_path, <<~CSV)
        id,region_id,identifier,is_main_series
        1,,national,1
      CSV

      PokePokedex.delete_all

      importer = Pokeapi::Importers::PokedexImporter.new(source_root: dir)
      assert_equal 1, importer.run!

      pokedex = PokePokedex.find(1)
      assert_equal "national", pokedex.name
      assert_nil pokedex.region_id
    end
  end
end
