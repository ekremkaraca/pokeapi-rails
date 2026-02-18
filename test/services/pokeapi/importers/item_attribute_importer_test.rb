require "test_helper"
require "fileutils"

class Pokeapi::Importers::ItemAttributeImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "item_flags.csv")

      File.write(csv_path, <<~CSV)
        id,identifier
        1,countable
        2,consumable
      CSV

      PokeItemAttribute.delete_all

      importer = Pokeapi::Importers::ItemAttributeImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeItemAttribute.count
      assert_equal "countable", PokeItemAttribute.find(1).name

      File.write(csv_path, <<~CSV)
        id,identifier
        1,countable-updated
        3,usable-overworld
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeItemAttribute.count
      assert_equal "countable-updated", PokeItemAttribute.find(1).name
      assert_equal "usable-overworld", PokeItemAttribute.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeItemAttribute.find(2) }
    end
  end
end
