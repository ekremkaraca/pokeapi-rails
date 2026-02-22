require "test_helper"
require "fileutils"

class Pokeapi::Importers::MoveEffectProseImporterTest < ActiveSupport::TestCase
  test "sanitizes XXX placeholder prose values" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "move_effect_prose.csv")

      language = PokeLanguage.create!(name: "move-effect-lang")
      language_two = PokeLanguage.create!(name: "move-effect-lang-two")

      File.write(csv_path, <<~CSV)
        move_effect_id,local_language_id,short_effect,effect
        1001,#{language.id},XXX new effect for move,XXX new effect for move
        1002,#{language_two.id},Valid short effect,Valid effect
      CSV

      PokeMoveEffectProse.delete_all

      importer = Pokeapi::Importers::MoveEffectProseImporter.new(source_root: dir)
      assert_equal 2, importer.run!

      placeholder_row = PokeMoveEffectProse.find_by!(move_effect_id: 1001, local_language_id: language.id)
      assert_nil placeholder_row.short_effect
      assert_nil placeholder_row.effect

      valid_row = PokeMoveEffectProse.find_by!(move_effect_id: 1002, local_language_id: language_two.id)
      assert_equal "Valid short effect", valid_row.short_effect
      assert_equal "Valid effect", valid_row.effect
    end
  end
end
