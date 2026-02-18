require "test_helper"
require "fileutils"

class Pokeapi::Importers::LanguageImporterTest < ActiveSupport::TestCase
  test "imports rows from csv and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "languages.csv")

      File.write(csv_path, <<~CSV)
        id,iso639,iso3166,identifier,official,order
        1,ja,jp,ja-hrkt,1,1
        9,en,us,en,1,7
      CSV

      PokeLanguage.delete_all

      importer = Pokeapi::Importers::LanguageImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeLanguage.count
      assert_equal "en", PokeLanguage.find(9).name

      File.write(csv_path, <<~CSV)
        id,iso639,iso3166,identifier,official,order
        9,en,us,en-updated,1,7
        13,pt,br,pt-br,0,13
      CSV

      assert_equal 2, importer.run!
      assert_equal 2, PokeLanguage.count
      assert_equal "en-updated", PokeLanguage.find(9).name
      assert_equal "pt-br", PokeLanguage.find(13).name
      assert_equal false, PokeLanguage.find(13).official
      assert_raises(ActiveRecord::RecordNotFound) { PokeLanguage.find(1) }
    end
  end

  test "handles blank order value" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "languages.csv")

      File.write(csv_path, <<~CSV)
        id,iso639,iso3166,identifier,official,order
        99,xx,yy,test-lang,0,
      CSV

      PokeLanguage.delete_all

      importer = Pokeapi::Importers::LanguageImporter.new(source_root: dir)
      assert_equal 1, importer.run!

      language = PokeLanguage.find(99)
      assert_equal "test-lang", language.name
      assert_nil language.sort_order
      assert_equal false, language.official
    end
  end
end
