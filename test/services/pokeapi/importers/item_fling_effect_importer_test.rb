require "test_helper"
require "fileutils"

class Pokeapi::Importers::ItemFlingEffectImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "item_fling_effects.csv")

      File.write(csv_path, <<~CSV)
        id,identifier
        1,burn
        2,poison
      CSV

      PokeItemFlingEffect.delete_all

      importer = Pokeapi::Importers::ItemFlingEffectImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeItemFlingEffect.count
      assert_equal "burn", PokeItemFlingEffect.find(1).name

      File.write(csv_path, <<~CSV)
        id,identifier
        1,burn-updated
        3,flinch
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeItemFlingEffect.count
      assert_equal "burn-updated", PokeItemFlingEffect.find(1).name
      assert_equal "flinch", PokeItemFlingEffect.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeItemFlingEffect.find(2) }
    end
  end
end
