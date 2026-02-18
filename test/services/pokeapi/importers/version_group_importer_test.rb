require "test_helper"
require "fileutils"

class Pokeapi::Importers::VersionGroupImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "version_groups.csv")

      File.write(csv_path, <<~CSV)
        id,identifier,generation_id,order
        1,red-blue,1,3
        2,yellow,1,4
      CSV

      PokeVersionGroup.delete_all

      importer = Pokeapi::Importers::VersionGroupImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeVersionGroup.count
      assert_equal "red-blue", PokeVersionGroup.find(1).name

      File.write(csv_path, <<~CSV)
        id,identifier,generation_id,order
        1,red-blue-updated,1,3
        3,gold-silver,2,5
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeVersionGroup.count
      assert_equal "red-blue-updated", PokeVersionGroup.find(1).name
      assert_equal "gold-silver", PokeVersionGroup.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeVersionGroup.find(2) }
    end
  end

  test "handles blank order value" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "version_groups.csv")

      File.write(csv_path, <<~CSV)
        id,identifier,generation_id,order
        30,legends-za,9,
      CSV

      PokeVersionGroup.delete_all

      importer = Pokeapi::Importers::VersionGroupImporter.new(source_root: dir)
      assert_equal 1, importer.run!

      vg = PokeVersionGroup.find(30)
      assert_equal "legends-za", vg.name
      assert_equal 9, vg.generation_id
      assert_nil vg.sort_order
    end
  end
end
