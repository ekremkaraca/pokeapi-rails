require "test_helper"
require "fileutils"

class Pokeapi::Importers::MoveBattleStyleImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "move_battle_styles.csv")

      File.write(csv_path, <<~CSV)
        id,identifier
        1,attack
        2,defense
      CSV

      PokeMoveBattleStyle.delete_all

      importer = Pokeapi::Importers::MoveBattleStyleImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeMoveBattleStyle.count
      assert_equal "attack", PokeMoveBattleStyle.find(1).name

      File.write(csv_path, <<~CSV)
        id,identifier
        1,attack-updated
        3,support
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeMoveBattleStyle.count
      assert_equal "attack-updated", PokeMoveBattleStyle.find(1).name
      assert_equal "support", PokeMoveBattleStyle.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeMoveBattleStyle.find(2) }
    end
  end
end
