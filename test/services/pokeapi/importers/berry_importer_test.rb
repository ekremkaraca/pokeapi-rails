require "test_helper"
require "fileutils"

class Pokeapi::Importers::BerryImporterTest < ActiveSupport::TestCase
  test "imports rows from csv, derives berry names from item names, and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "berries.csv")

      PokeItem.delete_all
      PokeBerry.delete_all
      PokeItem.create!(id: 126, name: "cheri-berry")
      PokeItem.create!(id: 127, name: "chesto-berry")
      PokeItem.create!(id: 128, name: "pecha-berry")

      File.write(csv_path, <<~CSV)
        id,item_id,firmness_id,natural_gift_power,natural_gift_type_id,size,max_harvest,growth_time,soil_dryness,smoothness
        1,126,2,60,10,20,5,3,15,25
        2,127,5,60,11,80,5,3,15,25
      CSV

      importer = Pokeapi::Importers::BerryImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeBerry.count
      assert_equal "cheri", PokeBerry.find(1).name
      assert_equal "chesto", PokeBerry.find(2).name
      assert_equal 2, PokeBerry.find(1).berry_firmness_id

      File.write(csv_path, <<~CSV)
        id,item_id,firmness_id,natural_gift_power,natural_gift_type_id,size,max_harvest,growth_time,soil_dryness,smoothness
        1,126,3,70,10,21,6,4,16,26
        3,128,1,60,13,40,5,3,15,25
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeBerry.count
      assert_equal "cheri", PokeBerry.find(1).name
      assert_equal 3, PokeBerry.find(1).berry_firmness_id
      assert_equal "pecha", PokeBerry.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeBerry.find(2) }
    end
  end
end
