require "test_helper"
require "fileutils"

class Pokeapi::Importers::PokemonColorImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "pokemon_colors.csv")

      File.write(csv_path, <<~CSV)
        id,identifier
        1,black
        2,blue
      CSV

      PokePokemonColor.delete_all

      importer = Pokeapi::Importers::PokemonColorImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokePokemonColor.count
      assert_equal "black", PokePokemonColor.find(1).name

      File.write(csv_path, <<~CSV)
        id,identifier
        1,black-updated
        3,brown
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokePokemonColor.count
      assert_equal "black-updated", PokePokemonColor.find(1).name
      assert_equal "brown", PokePokemonColor.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokePokemonColor.find(2) }
    end
  end
end
