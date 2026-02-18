require "test_helper"
require "fileutils"

class Pokeapi::Importers::EncounterConditionImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "encounter_conditions.csv")

      File.write(csv_path, <<~CSV)
        id,identifier
        1,swarm
        2,time
      CSV

      PokeEncounterCondition.delete_all

      importer = Pokeapi::Importers::EncounterConditionImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeEncounterCondition.count
      assert_equal "swarm", PokeEncounterCondition.find(1).name

      File.write(csv_path, <<~CSV)
        id,identifier
        1,swarm-updated
        3,radar
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeEncounterCondition.count
      assert_equal "swarm-updated", PokeEncounterCondition.find(1).name
      assert_equal "radar", PokeEncounterCondition.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeEncounterCondition.find(2) }
    end
  end
end
