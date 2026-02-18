require "test_helper"
require "fileutils"

class Pokeapi::Importers::BerryFirmnessImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "berry_firmness.csv")

      File.write(csv_path, <<~CSV)
        id,identifier
        1,very-soft
        2,soft
      CSV

      PokeBerryFirmness.delete_all

      importer = Pokeapi::Importers::BerryFirmnessImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeBerryFirmness.count
      assert_equal "very-soft", PokeBerryFirmness.find(1).name

      File.write(csv_path, <<~CSV)
        id,identifier
        1,very-soft-updated
        3,hard
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeBerryFirmness.count
      assert_equal "very-soft-updated", PokeBerryFirmness.find(1).name
      assert_equal "hard", PokeBerryFirmness.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeBerryFirmness.find(2) }
    end
  end
end
