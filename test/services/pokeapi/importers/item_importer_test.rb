require "test_helper"
require "fileutils"

class Pokeapi::Importers::ItemImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "items.csv")

      File.write(csv_path, <<~CSV)
        id,identifier,category_id,cost,fling_power,fling_effect_id
        1,master-ball,34,0,,
        17,potion,27,200,30,7
      CSV

      PokeItem.delete_all

      importer = Pokeapi::Importers::ItemImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeItem.count
      assert_equal "master-ball", PokeItem.find(1).name
      assert_nil PokeItem.find(1).fling_power
      assert_equal "potion", PokeItem.find(17).name
      assert_equal 30, PokeItem.find(17).fling_power
      assert_equal 7, PokeItem.find(17).fling_effect_id

      File.write(csv_path, <<~CSV)
        id,identifier,category_id,cost,fling_power,fling_effect_id
        1,master-ball-updated,34,1,,
        18,antidote,30,200,30,6
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeItem.count
      assert_equal "master-ball-updated", PokeItem.find(1).name
      assert_equal 1, PokeItem.find(1).cost
      assert_equal "antidote", PokeItem.find(18).name
      assert_equal 30, PokeItem.find(18).fling_power
      assert_equal 6, PokeItem.find(18).fling_effect_id
      assert_raises(ActiveRecord::RecordNotFound) { PokeItem.find(17) }
    end
  end

  test "allows duplicate item names present in source data" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "items.csv")

      File.write(csv_path, <<~CSV)
        id,identifier,category_id,cost,fling_power,fling_effect_id
        749,tm100,37,5000,,
        1943,tm100,37,0,,
      CSV

      PokeItem.delete_all

      importer = Pokeapi::Importers::ItemImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeItem.count
      assert_equal "tm100", PokeItem.find(749).name
      assert_equal "tm100", PokeItem.find(1943).name
    end
  end
end
