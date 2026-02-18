require "test_helper"
require "fileutils"

class Pokeapi::Importers::EvolutionTriggerImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "evolution_triggers.csv")

      File.write(csv_path, <<~CSV)
        id,identifier
        1,level-up
        2,trade
      CSV

      PokeEvolutionTrigger.delete_all

      importer = Pokeapi::Importers::EvolutionTriggerImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeEvolutionTrigger.count
      assert_equal "level-up", PokeEvolutionTrigger.find(1).name

      File.write(csv_path, <<~CSV)
        id,identifier
        1,level-up-updated
        3,use-item
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeEvolutionTrigger.count
      assert_equal "level-up-updated", PokeEvolutionTrigger.find(1).name
      assert_equal "use-item", PokeEvolutionTrigger.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeEvolutionTrigger.find(2) }
    end
  end
end
