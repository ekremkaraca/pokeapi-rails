require "test_helper"
require "fileutils"

class Pokeapi::Importers::PokemonFormImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "pokemon_forms.csv")

      File.write(csv_path, <<~CSV)
        id,identifier,form_identifier,pokemon_id,introduced_in_version_group_id,is_default,is_battle_only,is_mega,form_order,order
        1,bulbasaur,,1,28,1,0,0,1,1
        2,venusaur-mega,mega,10033,15,0,1,1,2,4
      CSV

      PokePokemonForm.delete_all

      importer = Pokeapi::Importers::PokemonFormImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokePokemonForm.count
      assert_nil PokePokemonForm.find(1).form_name
      assert_equal true, PokePokemonForm.find(2).is_mega

      File.write(csv_path, <<~CSV)
        id,identifier,form_identifier,pokemon_id,introduced_in_version_group_id,is_default,is_battle_only,is_mega,form_order,order
        1,bulbasaur-updated,default,1,28,1,0,0,1,11
        3,charizard-mega-x,mega-x,10034,15,0,1,1,2,7
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokePokemonForm.count
      assert_equal "bulbasaur-updated", PokePokemonForm.find(1).name
      assert_equal "default", PokePokemonForm.find(1).form_name
      assert_equal 11, PokePokemonForm.find(1).sort_order
      assert_equal "charizard-mega-x", PokePokemonForm.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokePokemonForm.find(2) }
    end
  end
end
