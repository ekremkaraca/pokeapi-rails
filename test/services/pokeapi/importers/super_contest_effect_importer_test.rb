require "test_helper"
require "fileutils"

class Pokeapi::Importers::SuperContestEffectImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "super_contest_effects.csv")

      File.write(csv_path, <<~CSV)
        id,appeal
        1,2
        2,2
      CSV

      PokeSuperContestEffect.delete_all

      importer = Pokeapi::Importers::SuperContestEffectImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeSuperContestEffect.count
      assert_equal 2, PokeSuperContestEffect.find(1).appeal

      File.write(csv_path, <<~CSV)
        id,appeal
        1,3
        4,2
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeSuperContestEffect.count
      assert_equal 3, PokeSuperContestEffect.find(1).appeal
      assert_equal 2, PokeSuperContestEffect.find(4).appeal
      assert_raises(ActiveRecord::RecordNotFound) { PokeSuperContestEffect.find(2) }
    end
  end
end
