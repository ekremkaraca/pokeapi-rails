require "test_helper"
require "fileutils"

class Pokeapi::Importers::ItemPocketImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "item_pockets.csv")

      File.write(csv_path, <<~CSV)
        id,identifier
        1,misc
        2,medicine
      CSV

      PokeItemPocket.delete_all

      importer = Pokeapi::Importers::ItemPocketImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeItemPocket.count
      assert_equal "misc", PokeItemPocket.find(1).name

      File.write(csv_path, <<~CSV)
        id,identifier
        1,misc-updated
        3,pokeballs
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeItemPocket.count
      assert_equal "misc-updated", PokeItemPocket.find(1).name
      assert_equal "pokeballs", PokeItemPocket.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeItemPocket.find(2) }
    end
  end
end
