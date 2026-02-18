require "test_helper"
require "fileutils"

class Pokeapi::Importers::PokemonSpeciesImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "pokemon_species.csv")

      File.write(csv_path, <<~CSV)
        id,identifier,generation_id,evolves_from_species_id,evolution_chain_id,color_id,shape_id,habitat_id,gender_rate,capture_rate,base_happiness,is_baby,hatch_counter,has_gender_differences,growth_rate_id,forms_switchable,is_legendary,is_mythical,order,conquest_order
        1,bulbasaur,1,,1,5,8,3,1,45,70,0,20,0,4,0,0,0,1,
        2,ivysaur,1,1,1,5,8,3,1,45,70,0,20,0,4,0,0,0,2,
      CSV

      PokePokemonSpecies.delete_all

      importer = Pokeapi::Importers::PokemonSpeciesImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokePokemonSpecies.count
      assert_equal "bulbasaur", PokePokemonSpecies.find(1).name
      assert_equal false, PokePokemonSpecies.find(1).is_mythical
      assert_equal 1, PokePokemonSpecies.find(2).evolves_from_species_id

      File.write(csv_path, <<~CSV)
        id,identifier,generation_id,evolves_from_species_id,evolution_chain_id,color_id,shape_id,habitat_id,gender_rate,capture_rate,base_happiness,is_baby,hatch_counter,has_gender_differences,growth_rate_id,forms_switchable,is_legendary,is_mythical,order,conquest_order
        1,bulbasaur-updated,1,,1,5,8,3,1,45,90,0,20,0,4,1,0,0,10,
        3,venusaur,1,2,1,5,8,3,1,45,70,0,20,0,4,1,0,0,3,
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokePokemonSpecies.count
      assert_equal "bulbasaur-updated", PokePokemonSpecies.find(1).name
      assert_equal 90, PokePokemonSpecies.find(1).base_happiness
      assert_equal true, PokePokemonSpecies.find(1).forms_switchable
      assert_equal 10, PokePokemonSpecies.find(1).sort_order
      assert_equal "venusaur", PokePokemonSpecies.find(3).name
      assert_raises(ActiveRecord::RecordNotFound) { PokePokemonSpecies.find(2) }
    end
  end
end
