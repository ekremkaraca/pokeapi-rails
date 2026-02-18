require "test_helper"
require "fileutils"

class Pokeapi::Importers::ItemCategoryImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "item_categories.csv")

      File.write(csv_path, <<~CSV)
        id,pocket_id,identifier
        1,7,stat-boosts
        2,5,effort-drop
      CSV

      PokeItemCategory.delete_all

      importer = Pokeapi::Importers::ItemCategoryImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeItemCategory.count
      assert_equal "stat-boosts", PokeItemCategory.find(1).name
      assert_equal 7, PokeItemCategory.find(1).pocket_id

      File.write(csv_path, <<~CSV)
        id,pocket_id,identifier
        1,8,stat-boosts-updated
        3,5,medicine
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeItemCategory.count
      assert_equal "stat-boosts-updated", PokeItemCategory.find(1).name
      assert_equal 8, PokeItemCategory.find(1).pocket_id
      assert_equal "medicine", PokeItemCategory.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeItemCategory.find(2) }
    end
  end
end
