class CreateCharacteristic < ActiveRecord::Migration[8.1]
  def change
    create_table :characteristic do |t|
      t.integer :stat_id
      t.integer :gene_mod_5

      t.timestamps
    end

    add_index :characteristic, :stat_id
    add_index :characteristic, :gene_mod_5
  end
end
