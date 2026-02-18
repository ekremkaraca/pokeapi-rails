require "test_helper"
require "fileutils"

class Pokeapi::Importers::NatureImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "natures.csv")

      File.write(csv_path, <<~CSV)
        id,identifier,decreased_stat_id,increased_stat_id,hates_flavor_id,likes_flavor_id,game_index
        1,hardy,2,2,1,1,0
        2,bold,2,3,1,2,1
      CSV

      PokeNature.delete_all

      importer = Pokeapi::Importers::NatureImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeNature.count
      assert_equal "hardy", PokeNature.find(1).name
      assert_equal 3, PokeNature.find(2).increased_stat_id

      File.write(csv_path, <<~CSV)
        id,identifier,decreased_stat_id,increased_stat_id,hates_flavor_id,likes_flavor_id,game_index
        1,hardy-updated,2,4,1,3,8
        3,timid,2,6,1,5,10
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeNature.count
      assert_equal "hardy-updated", PokeNature.find(1).name
      assert_equal 8, PokeNature.find(1).game_index
      assert_equal "timid", PokeNature.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeNature.find(2) }
    end
  end
end
