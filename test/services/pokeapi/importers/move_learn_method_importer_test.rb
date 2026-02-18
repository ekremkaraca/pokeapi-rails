require "test_helper"
require "fileutils"

class Pokeapi::Importers::MoveLearnMethodImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "pokemon_move_methods.csv")

      File.write(csv_path, <<~CSV)
        id,identifier
        1,level-up
        2,egg
      CSV

      PokeMoveLearnMethod.delete_all

      importer = Pokeapi::Importers::MoveLearnMethodImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeMoveLearnMethod.count
      assert_equal "level-up", PokeMoveLearnMethod.find(1).name

      File.write(csv_path, <<~CSV)
        id,identifier
        1,level-up-updated
        3,tutor
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeMoveLearnMethod.count
      assert_equal "level-up-updated", PokeMoveLearnMethod.find(1).name
      assert_equal "tutor", PokeMoveLearnMethod.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeMoveLearnMethod.find(2) }
    end
  end
end
