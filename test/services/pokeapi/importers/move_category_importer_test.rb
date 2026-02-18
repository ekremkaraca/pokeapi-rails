require "test_helper"
require "fileutils"

class Pokeapi::Importers::MoveCategoryImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "move_meta_categories.csv")

      File.write(csv_path, <<~CSV)
        id,identifier
        0,damage
        1,ailment
      CSV

      PokeMoveMetaCategory.delete_all

      importer = Pokeapi::Importers::MoveCategoryImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeMoveMetaCategory.count
      assert_equal "damage", PokeMoveMetaCategory.find(0).name

      File.write(csv_path, <<~CSV)
        id,identifier
        0,damage-updated
        3,heal
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeMoveMetaCategory.count
      assert_equal "damage-updated", PokeMoveMetaCategory.find(0).name
      assert_equal "heal", PokeMoveMetaCategory.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeMoveMetaCategory.find(1) }
    end
  end
end
