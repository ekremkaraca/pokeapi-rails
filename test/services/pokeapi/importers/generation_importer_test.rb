require "test_helper"
require "fileutils"

class Pokeapi::Importers::GenerationImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "generations.csv")

      File.write(csv_path, <<~CSV)
        id,main_region_id,identifier
        1,1,generation-i
        2,2,generation-ii
      CSV

      PokeGeneration.delete_all

      importer = Pokeapi::Importers::GenerationImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeGeneration.count
      assert_equal "generation-i", PokeGeneration.find(1).name

      File.write(csv_path, <<~CSV)
        id,main_region_id,identifier
        1,1,generation-i-updated
        3,3,generation-iii
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeGeneration.count
      assert_equal "generation-i-updated", PokeGeneration.find(1).name
      assert_equal "generation-iii", PokeGeneration.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeGeneration.find(2) }
    end
  end

  test "handles blank main_region_id" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "generations.csv")

      File.write(csv_path, <<~CSV)
        id,main_region_id,identifier
        9,,generation-ix
      CSV

      PokeGeneration.delete_all

      importer = Pokeapi::Importers::GenerationImporter.new(source_root: dir)
      assert_equal 1, importer.run!

      generation = PokeGeneration.find(9)
      assert_equal "generation-ix", generation.name
      assert_nil generation.main_region_id
    end
  end
end
