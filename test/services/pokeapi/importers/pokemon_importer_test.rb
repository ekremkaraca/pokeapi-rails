require "test_helper"
require "fileutils"

class Pokeapi::Importers::PokemonImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "pokemon.csv")

      File.write(csv_path, <<~CSV)
        id,identifier,species_id,height,weight,base_experience,order,is_default
        1,bulbasaur,1,7,69,64,1,1
        2,ivysaur,2,10,130,142,2,1
      CSV

      Pokemon.delete_all

      importer = Pokeapi::Importers::PokemonImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, Pokemon.count
      assert_equal "bulbasaur", Pokemon.find(1).name

      File.write(csv_path, <<~CSV)
        id,identifier,species_id,height,weight,base_experience,order,is_default
        1,bulbasaur-updated,1,7,69,64,1,1
        3,venusaur,3,20,1000,236,3,1
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, Pokemon.count
      assert_equal "bulbasaur-updated", Pokemon.find(1).name
      assert_equal "venusaur", Pokemon.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { Pokemon.find(2) }
    end
  end

  test "allows blank order values" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "pokemon.csv")

      File.write(csv_path, <<~CSV)
        id,identifier,species_id,height,weight,base_experience,order,is_default
        899,wyrdeer,899,18,951,263,,1
      CSV

      Pokemon.delete_all

      importer = Pokeapi::Importers::PokemonImporter.new(source_root: dir)
      assert_equal 1, importer.run!

      pokemon = Pokemon.find(899)
      assert_equal "wyrdeer", pokemon.name
      assert_nil pokemon.sort_order
    end
  end

  test "allows blank base_experience values" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "pokemon.csv")

      File.write(csv_path, <<~CSV)
        id,identifier,species_id,height,weight,base_experience,order,is_default
        10278,clefable-mega,36,17,423,,,0
      CSV

      Pokemon.delete_all

      importer = Pokeapi::Importers::PokemonImporter.new(source_root: dir)
      assert_equal 1, importer.run!

      pokemon = Pokemon.find(10278)
      assert_equal "clefable-mega", pokemon.name
      assert_nil pokemon.base_experience
    end
  end
end
