require "test_helper"
require "fileutils"

class Pokeapi::Importers::TypeImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "types.csv")

      File.write(csv_path, <<~CSV)
        id,identifier,generation_id,damage_class_id
        1,normal,1,2
        2,fighting,1,2
      CSV

      PokeType.delete_all

      importer = Pokeapi::Importers::TypeImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeType.count
      assert_equal "normal", PokeType.find(1).name

      File.write(csv_path, <<~CSV)
        id,identifier,generation_id,damage_class_id
        1,normal-updated,1,2
        3,flying,1,2
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeType.count
      assert_equal "normal-updated", PokeType.find(1).name
      assert_equal "flying", PokeType.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeType.find(2) }
    end
  end

  test "handles blank damage_class_id" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "types.csv")

      File.write(csv_path, <<~CSV)
        id,identifier,generation_id,damage_class_id
        18,fairy,6,
      CSV

      PokeType.delete_all

      importer = Pokeapi::Importers::TypeImporter.new(source_root: dir)
      assert_equal 1, importer.run!

      type = PokeType.find(18)
      assert_equal "fairy", type.name
      assert_equal 6, type.generation_id
      assert_nil type.damage_class_id
    end
  end
end
