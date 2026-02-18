require "test_helper"
require "fileutils"

class Pokeapi::Importers::BerryFlavorImporterTest < ActiveSupport::TestCase
  test "imports english flavor rows from contest type names and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "contest_type_names.csv")

      File.write(csv_path, <<~CSV)
        contest_type_id,local_language_id,name,flavor,color
        1,9,Cool,Spicy,Red
        1,5,Sang-froid,Épicé,Rouge
        2,9,Beauty,Dry,Blue
      CSV

      PokeBerryFlavor.delete_all

      importer = Pokeapi::Importers::BerryFlavorImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeBerryFlavor.count
      assert_equal "spicy", PokeBerryFlavor.find(1).name
      assert_equal "dry", PokeBerryFlavor.find(2).name

      File.write(csv_path, <<~CSV)
        contest_type_id,local_language_id,name,flavor,color
        1,9,Cool,SpicyPlus,Red
        3,9,Cute,Sweet,Pink
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeBerryFlavor.count
      assert_equal "spicyplus", PokeBerryFlavor.find(1).name
      assert_equal "sweet", PokeBerryFlavor.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokeBerryFlavor.find(2) }
    end
  end
end
