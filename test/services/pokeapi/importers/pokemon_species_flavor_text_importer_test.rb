require "test_helper"
require "fileutils"

class Pokeapi::Importers::PokemonSpeciesFlavorTextImporterTest < ActiveSupport::TestCase
  test "imports multiline flavor text rows" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "pokemon_species_flavor_text.csv")

      File.write(csv_path, <<~CSV)
        species_id,version_id,language_id,flavor_text
        1,1,9,"line one
        line ""two"""
        2,1,9,"single line"
      CSV

      PokePokemonSpeciesFlavorText.delete_all

      importer = Pokeapi::Importers::PokemonSpeciesFlavorTextImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokePokemonSpeciesFlavorText.count

      first = PokePokemonSpeciesFlavorText.find_by!(species_id: 1, version_id: 1, language_id: 9)
      assert_equal "line one\nline \"two\"", first.flavor_text
    end
  end

  test "raises on malformed multiline row and rolls back table changes" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "pokemon_species_flavor_text.csv")

      File.write(csv_path, <<~CSV)
        species_id,version_id,language_id,flavor_text
        1,1,9,"unterminated
      CSV

      PokePokemonSpeciesFlavorText.delete_all
      existing = PokePokemonSpeciesFlavorText.create!(
        species_id: 999,
        version_id: 1,
        language_id: 9,
        flavor_text: "existing"
      )

      importer = Pokeapi::Importers::PokemonSpeciesFlavorTextImporter.new(source_root: dir)
      assert_raises(Pokeapi::Importers::PokemonSpeciesFlavorTextImporter::MalformedCsvRowError) do
        importer.run!
      end

      assert_equal 1, PokePokemonSpeciesFlavorText.count
      assert_equal existing.id, PokePokemonSpeciesFlavorText.first.id
    end
  end

  test "skips unchanged csv when enabled" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "pokemon_species_flavor_text.csv")
      checksum_file = File.join(dir, "tmp/import_checksums.json")

      File.write(csv_path, <<~CSV)
        species_id,version_id,language_id,flavor_text
        1,1,9,"line one"
      CSV

      PokePokemonSpeciesFlavorText.delete_all

      with_env("POKEAPI_SKIP_UNCHANGED" => "1", "POKEAPI_IMPORT_CHECKSUM_FILE" => checksum_file) do
        importer = Pokeapi::Importers::PokemonSpeciesFlavorTextImporter.new(source_root: dir)
        assert_equal 1, importer.run!
        assert_equal false, importer.last_run_skipped?

        PokePokemonSpeciesFlavorText.create!(species_id: 999, version_id: 1, language_id: 9, flavor_text: "manual")

        assert_equal 0, importer.run!
        assert_equal true, importer.last_run_skipped?
        assert PokePokemonSpeciesFlavorText.exists?(species_id: 999)
      end
    end
  end

  private

  def with_env(overrides)
    original = overrides.transform_values { nil }
    overrides.each_key { |key| original[key] = ENV[key] }
    overrides.each { |key, value| ENV[key] = value }
    yield
  ensure
    original.each { |key, value| ENV[key] = value }
  end
end
