require "test_helper"
require "fileutils"

class Pokeapi::Importers::MoveAilmentImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "move_meta_ailments.csv")

      File.write(csv_path, <<~CSV)
        id,identifier
        -1,unknown
        0,none
      CSV

      PokeMoveAilment.delete_all

      importer = Pokeapi::Importers::MoveAilmentImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeMoveAilment.count
      assert_equal "unknown", PokeMoveAilment.find(-1).name

      File.write(csv_path, <<~CSV)
        id,identifier
        -1,unknown-updated
        1,paralysis
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeMoveAilment.count
      assert_equal "unknown-updated", PokeMoveAilment.find(-1).name
      assert_equal "paralysis", PokeMoveAilment.find(1).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeMoveAilment.find(0) }
    end
  end
end
