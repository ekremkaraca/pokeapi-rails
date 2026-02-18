require "test_helper"
require "fileutils"

class Pokeapi::Importers::StatImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "stats.csv")

      File.write(csv_path, <<~CSV)
        id,damage_class_id,identifier,is_battle_only,game_index
        1,,hp,0,1
        2,2,attack,0,2
      CSV

      PokeStat.delete_all

      importer = Pokeapi::Importers::StatImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeStat.count
      assert_equal "hp", PokeStat.find(1).name

      File.write(csv_path, <<~CSV)
        id,damage_class_id,identifier,is_battle_only,game_index
        1,,hp-updated,0,1
        7,,accuracy,1,
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeStat.count
      assert_equal "hp-updated", PokeStat.find(1).name
      assert_equal "accuracy", PokeStat.find(7).name
      assert_equal true, PokeStat.find(7).is_battle_only
      assert_nil PokeStat.find(7).game_index
      assert_raises(ActiveRecord::RecordNotFound) { PokeStat.find(2) }
    end
  end

  test "handles blank damage_class_id" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "stats.csv")

      File.write(csv_path, <<~CSV)
        id,damage_class_id,identifier,is_battle_only,game_index
        6,,speed,0,4
      CSV

      PokeStat.delete_all

      importer = Pokeapi::Importers::StatImporter.new(source_root: dir)
      assert_equal 1, importer.run!

      stat = PokeStat.find(6)
      assert_equal "speed", stat.name
      assert_nil stat.damage_class_id
    end
  end
end
