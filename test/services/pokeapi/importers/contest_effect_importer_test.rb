require "test_helper"
require "fileutils"

class Pokeapi::Importers::ContestEffectImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "contest_effects.csv")

      File.write(csv_path, <<~CSV)
        id,appeal,jam
        1,4,0
        2,3,0
      CSV

      PokeContestEffect.delete_all

      importer = Pokeapi::Importers::ContestEffectImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeContestEffect.count
      assert_equal 4, PokeContestEffect.find(1).appeal
      assert_equal 0, PokeContestEffect.find(1).jam

      File.write(csv_path, <<~CSV)
        id,appeal,jam
        1,8,1
        3,2,2
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeContestEffect.count
      assert_equal 8, PokeContestEffect.find(1).appeal
      assert_equal 1, PokeContestEffect.find(1).jam
      assert_equal 2, PokeContestEffect.find(3).appeal
      assert_raises(ActiveRecord::RecordNotFound) { PokeContestEffect.find(2) }
    end
  end
end
