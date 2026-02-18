require "test_helper"
require "fileutils"

class Pokeapi::Importers::AbilityImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "abilities.csv")

      File.write(csv_path, <<~CSV)
        id,identifier,generation_id,is_main_series
        1,stench,3,1
        2,drizzle,3,1
      CSV

      Ability.delete_all

      importer = Pokeapi::Importers::AbilityImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, Ability.count
      assert_equal "stench", Ability.find(1).name

      File.write(csv_path, <<~CSV)
        id,identifier,generation_id,is_main_series
        1,stench-updated,3,1
        3,shadow-tag,3,1
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, Ability.count
      assert_equal "stench-updated", Ability.find(1).name
      assert_equal "shadow-tag", Ability.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { Ability.find(2) }
    end
  end

  test "handles blank generation_id" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "abilities.csv")

      File.write(csv_path, <<~CSV)
        id,identifier,generation_id,is_main_series
        999,test-ability,,0
      CSV

      Ability.delete_all

      importer = Pokeapi::Importers::AbilityImporter.new(source_root: dir)
      assert_equal 1, importer.run!

      ability = Ability.find(999)
      assert_equal "test-ability", ability.name
      assert_nil ability.generation_id
      assert_equal false, ability.is_main_series
    end
  end
end
