require "test_helper"
require "fileutils"

class Pokeapi::Importers::PokemonShapeImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "pokemon_shapes.csv")

      File.write(csv_path, <<~CSV)
        id,identifier
        1,ball
        2,squiggle
      CSV

      PokePokemonShape.delete_all

      importer = Pokeapi::Importers::PokemonShapeImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokePokemonShape.count
      assert_equal "ball", PokePokemonShape.find(1).name

      File.write(csv_path, <<~CSV)
        id,identifier
        1,ball-updated
        3,fish
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokePokemonShape.count
      assert_equal "ball-updated", PokePokemonShape.find(1).name
      assert_equal "fish", PokePokemonShape.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokePokemonShape.find(2) }
    end
  end
end
