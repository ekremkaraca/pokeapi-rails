require "test_helper"
require "fileutils"

class Pokeapi::Importers::PokemonHabitatImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "pokemon_habitats.csv")

      File.write(csv_path, <<~CSV)
        id,identifier
        1,cave
        2,forest
      CSV

      PokePokemonHabitat.delete_all

      importer = Pokeapi::Importers::PokemonHabitatImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokePokemonHabitat.count
      assert_equal "cave", PokePokemonHabitat.find(1).name

      File.write(csv_path, <<~CSV)
        id,identifier
        1,cave-updated
        3,grassland
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokePokemonHabitat.count
      assert_equal "cave-updated", PokePokemonHabitat.find(1).name
      assert_equal "grassland", PokePokemonHabitat.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokePokemonHabitat.find(2) }
    end
  end
end
