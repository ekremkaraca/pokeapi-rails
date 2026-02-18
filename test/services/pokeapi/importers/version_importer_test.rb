require "test_helper"
require "fileutils"

class Pokeapi::Importers::VersionImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "versions.csv")

      File.write(csv_path, <<~CSV)
        id,version_group_id,identifier
        1,1,red
        2,1,blue
      CSV

      PokeVersion.delete_all

      importer = Pokeapi::Importers::VersionImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeVersion.count
      assert_equal "red", PokeVersion.find(1).name

      File.write(csv_path, <<~CSV)
        id,version_group_id,identifier
        1,1,red-updated
        3,2,yellow
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeVersion.count
      assert_equal "red-updated", PokeVersion.find(1).name
      assert_equal "yellow", PokeVersion.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeVersion.find(2) }
    end
  end

  test "handles blank version_group_id" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "versions.csv")

      File.write(csv_path, <<~CSV)
        id,version_group_id,identifier
        200,,test-version
      CSV

      PokeVersion.delete_all

      importer = Pokeapi::Importers::VersionImporter.new(source_root: dir)
      assert_equal 1, importer.run!

      version = PokeVersion.find(200)
      assert_equal "test-version", version.name
      assert_nil version.version_group_id
    end
  end
end
