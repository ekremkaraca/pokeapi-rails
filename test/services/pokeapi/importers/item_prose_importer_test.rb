require "test_helper"
require "fileutils"

class Pokeapi::Importers::ItemProseImporterTest < ActiveSupport::TestCase
  test "sanitizes XXX placeholder prose values" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "item_prose.csv")

      item = PokeItem.create!(name: "item-prose-target")
      language = PokeLanguage.create!(name: "item-prose-lang")
      language_two = PokeLanguage.create!(name: "item-prose-lang-two")

      File.write(csv_path, <<~CSV)
        item_id,local_language_id,short_effect,effect
        #{item.id},#{language.id},XXX new effect for item,XXX new effect for item
        #{item.id},#{language_two.id},Valid short effect,Valid effect
      CSV

      PokeItemProse.delete_all

      importer = Pokeapi::Importers::ItemProseImporter.new(source_root: dir)
      assert_equal 2, importer.run!

      placeholder_row = PokeItemProse.find_by!(item_id: item.id, local_language_id: language.id)
      assert_nil placeholder_row.short_effect
      assert_nil placeholder_row.effect

      valid_row = PokeItemProse.find_by!(item_id: item.id, local_language_id: language_two.id)
      assert_equal "Valid short effect", valid_row.short_effect
      assert_equal "Valid effect", valid_row.effect
    end
  end
end
