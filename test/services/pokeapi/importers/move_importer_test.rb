require "test_helper"
require "fileutils"

class Pokeapi::Importers::MoveImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "moves.csv")

      File.write(csv_path, <<~CSV)
        id,identifier,generation_id,type_id,power,pp,accuracy,priority,target_id,damage_class_id,effect_id,effect_chance,contest_type_id,contest_effect_id,super_contest_effect_id
        1,pound,1,1,40,35,100,0,10,2,1,,5,1,5
        2,karate-chop,1,2,50,25,100,0,10,2,2,,5,2,6
      CSV

      PokeMove.delete_all

      importer = Pokeapi::Importers::MoveImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeMove.count
      assert_equal "pound", PokeMove.find(1).name
      assert_equal 40, PokeMove.find(1).power

      File.write(csv_path, <<~CSV)
        id,identifier,generation_id,type_id,power,pp,accuracy,priority,target_id,damage_class_id,effect_id,effect_chance,contest_type_id,contest_effect_id,super_contest_effect_id
        1,pound-updated,1,1,55,35,100,1,10,2,1,,5,1,5
        3,double-slap,1,1,15,10,85,0,10,2,3,,5,3,5
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeMove.count
      assert_equal "pound-updated", PokeMove.find(1).name
      assert_equal 55, PokeMove.find(1).power
      assert_equal "double-slap", PokeMove.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeMove.find(2) }
    end
  end

  test "skips unchanged csv when enabled" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "moves.csv")
      checksum_file = File.join(dir, "tmp/import_checksums.json")

      File.write(csv_path, <<~CSV)
        id,identifier,generation_id,type_id,power,pp,accuracy,priority,target_id,damage_class_id,effect_id,effect_chance,contest_type_id,contest_effect_id,super_contest_effect_id
        1,pound,1,1,40,35,100,0,10,2,1,,5,1,5
        2,karate-chop,1,2,50,25,100,0,10,2,2,,5,2,6
      CSV

      PokeMove.delete_all

      with_env("POKEAPI_SKIP_UNCHANGED" => "1", "POKEAPI_IMPORT_CHECKSUM_FILE" => checksum_file) do
        importer = Pokeapi::Importers::MoveImporter.new(source_root: dir)
        assert_equal 2, importer.run!
        assert_equal false, importer.last_run_skipped?

        PokeMove.create!(name: "manual-extra-row")

        assert_equal 0, importer.run!
        assert_equal true, importer.last_run_skipped?
        assert PokeMove.exists?(name: "manual-extra-row")

        File.write(csv_path, <<~CSV)
          id,identifier,generation_id,type_id,power,pp,accuracy,priority,target_id,damage_class_id,effect_id,effect_chance,contest_type_id,contest_effect_id,super_contest_effect_id
          1,pound-updated,1,1,55,35,100,1,10,2,1,,5,1,5
          3,double-slap,1,1,15,10,85,0,10,2,3,,5,3,5
        CSV

        assert_equal 2, importer.run!
        assert_equal false, importer.last_run_skipped?
        assert_equal false, PokeMove.exists?(name: "manual-extra-row")
      end
    end
  end

  private

  def with_env(overrides)
    original = overrides.transform_values { nil }
    overrides.each_key { |key| original[key] = ENV[key] }
    overrides.each { |key, value| ENV[key] = value }
    yield
  ensure
    original.each { |key, value| ENV[key] = value }
  end
end
