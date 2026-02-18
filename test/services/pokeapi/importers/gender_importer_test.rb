require "test_helper"
require "fileutils"

class Pokeapi::Importers::GenderImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "genders.csv")

      File.write(csv_path, <<~CSV)
        id,identifier
        1,female
        2,male
      CSV

      PokeGender.delete_all

      importer = Pokeapi::Importers::GenderImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeGender.count
      assert_equal "female", PokeGender.find(1).name

      File.write(csv_path, <<~CSV)
        id,identifier
        1,female-updated
        3,genderless
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeGender.count
      assert_equal "female-updated", PokeGender.find(1).name
      assert_equal "genderless", PokeGender.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeGender.find(2) }
    end
  end
end
