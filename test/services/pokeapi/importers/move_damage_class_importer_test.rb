require "test_helper"
require "fileutils"

class Pokeapi::Importers::MoveDamageClassImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "move_damage_classes.csv")

      File.write(csv_path, <<~CSV)
        id,identifier
        1,status
        2,physical
      CSV

      PokeMoveDamageClass.delete_all

      importer = Pokeapi::Importers::MoveDamageClassImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeMoveDamageClass.count
      assert_equal "status", PokeMoveDamageClass.find(1).name

      File.write(csv_path, <<~CSV)
        id,identifier
        1,status-updated
        3,special
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeMoveDamageClass.count
      assert_equal "status-updated", PokeMoveDamageClass.find(1).name
      assert_equal "special", PokeMoveDamageClass.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeMoveDamageClass.find(2) }
    end
  end
end
