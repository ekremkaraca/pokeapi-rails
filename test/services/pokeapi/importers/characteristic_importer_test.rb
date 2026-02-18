require "test_helper"
require "fileutils"

class Pokeapi::Importers::CharacteristicImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "characteristics.csv")

      File.write(csv_path, <<~CSV)
        id,stat_id,gene_mod_5
        1,1,0
        2,2,1
      CSV

      PokeCharacteristic.delete_all

      importer = Pokeapi::Importers::CharacteristicImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeCharacteristic.count
      assert_equal 1, PokeCharacteristic.find(1).stat_id
      assert_equal 0, PokeCharacteristic.find(1).gene_mod_5

      File.write(csv_path, <<~CSV)
        id,stat_id,gene_mod_5
        1,3,4
        3,6,2
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeCharacteristic.count
      assert_equal 3, PokeCharacteristic.find(1).stat_id
      assert_equal 4, PokeCharacteristic.find(1).gene_mod_5
      assert_equal 2, PokeCharacteristic.find(3).gene_mod_5
      assert_raises(ActiveRecord::RecordNotFound) { PokeCharacteristic.find(2) }
    end
  end
end
