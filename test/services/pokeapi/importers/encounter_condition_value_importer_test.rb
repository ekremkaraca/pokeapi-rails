require "test_helper"
require "fileutils"

class Pokeapi::Importers::EncounterConditionValueImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "encounter_condition_values.csv")

      File.write(csv_path, <<~CSV)
        id,encounter_condition_id,identifier,is_default
        1,1,swarm-yes,0
        2,1,swarm-no,1
      CSV

      PokeEncounterConditionValue.delete_all

      importer = Pokeapi::Importers::EncounterConditionValueImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeEncounterConditionValue.count
      assert_equal "swarm-yes", PokeEncounterConditionValue.find(1).name
      assert_equal false, PokeEncounterConditionValue.find(1).is_default
      assert_equal true, PokeEncounterConditionValue.find(2).is_default

      File.write(csv_path, <<~CSV)
        id,encounter_condition_id,identifier,is_default
        1,1,swarm-yes-updated,1
        3,2,time-day,1
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeEncounterConditionValue.count
      assert_equal "swarm-yes-updated", PokeEncounterConditionValue.find(1).name
      assert_equal true, PokeEncounterConditionValue.find(1).is_default
      assert_equal 2, PokeEncounterConditionValue.find(3).encounter_condition_id
      assert_raises(ActiveRecord::RecordNotFound) { PokeEncounterConditionValue.find(2) }
    end
  end
end
