require "test_helper"
require "fileutils"

class Pokeapi::Importers::MoveTargetImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "move_targets.csv")

      File.write(csv_path, <<~CSV)
        id,identifier
        1,specific-move
        2,selected-pokemon-me-first
      CSV

      PokeMoveTarget.delete_all

      importer = Pokeapi::Importers::MoveTargetImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeMoveTarget.count
      assert_equal "specific-move", PokeMoveTarget.find(1).name

      File.write(csv_path, <<~CSV)
        id,identifier
        1,specific-move-updated
        3,ally
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeMoveTarget.count
      assert_equal "specific-move-updated", PokeMoveTarget.find(1).name
      assert_equal "ally", PokeMoveTarget.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeMoveTarget.find(2) }
    end
  end
end
