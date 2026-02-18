require "test_helper"
require "fileutils"

class Pokeapi::Importers::EvolutionChainImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "evolution_chains.csv")

      File.write(csv_path, <<~CSV)
        id,baby_trigger_item_id
        1,
        2,231
      CSV

      PokeEvolutionChain.delete_all

      importer = Pokeapi::Importers::EvolutionChainImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeEvolutionChain.count
      assert_nil PokeEvolutionChain.find(1).baby_trigger_item_id
      assert_equal 231, PokeEvolutionChain.find(2).baby_trigger_item_id

      File.write(csv_path, <<~CSV)
        id,baby_trigger_item_id
        1,200
        3,
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeEvolutionChain.count
      assert_equal 200, PokeEvolutionChain.find(1).baby_trigger_item_id
      assert_nil PokeEvolutionChain.find(3).baby_trigger_item_id
      assert_raises(ActiveRecord::RecordNotFound) { PokeEvolutionChain.find(2) }
    end
  end
end
