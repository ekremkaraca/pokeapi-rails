require "test_helper"
require "fileutils"

class Pokeapi::Importers::MachineImporterTest < ActiveSupport::TestCase
  test "imports rows from csv with deterministic generated ids and rebuilds table state" do
    Dir.mktmpdir do |dir|
      csv_dir = File.join(dir, "data/v2/csv")
      FileUtils.mkdir_p(csv_dir)
      csv_path = File.join(csv_dir, "machines.csv")

      File.write(csv_path, <<~CSV)
        machine_number,version_group_id,item_id,move_id
        0,20,1288,5
        1,20,1164,13
      CSV

      PokeMachine.delete_all

      importer = Pokeapi::Importers::MachineImporter.new(source_root: dir)
      assert_equal 2, importer.run!
      assert_equal 2, PokeMachine.count
      assert_equal [ 1, 2 ], PokeMachine.order(:id).pluck(:id)
      assert_equal 0, PokeMachine.find(1).machine_number
      assert_equal 13, PokeMachine.find(2).move_id

      File.write(csv_path, <<~CSV)
        machine_number,version_group_id,item_id,move_id
        10,21,1000,200
      CSV

      assert_equal 1, importer.run!
      assert_equal 1, PokeMachine.count
      assert_equal 1, PokeMachine.first.id
      assert_equal 10, PokeMachine.first.machine_number
    end
  end
end
