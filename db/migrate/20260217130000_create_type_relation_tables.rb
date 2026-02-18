class CreateTypeRelationTables < ActiveRecord::Migration[8.1]
  def change
    create_table :type_efficacy do |t|
      t.integer :damage_type_id, null: false
      t.integer :target_type_id, null: false
      t.integer :damage_factor, null: false

      t.timestamps
    end
    add_index :type_efficacy, [ :damage_type_id, :target_type_id ], unique: true
    add_index :type_efficacy, :target_type_id

    create_table :type_efficacy_past do |t|
      t.integer :damage_type_id, null: false
      t.integer :target_type_id, null: false
      t.integer :damage_factor, null: false
      t.integer :generation_id, null: false

      t.timestamps
    end
    add_index :type_efficacy_past, [ :damage_type_id, :target_type_id, :generation_id ], unique: true, name: "idx_type_efficacy_past_unique"
    add_index :type_efficacy_past, :generation_id
    add_index :type_efficacy_past, :target_type_id

    create_table :type_game_index do |t|
      t.integer :type_id, null: false
      t.integer :generation_id, null: false
      t.integer :game_index, null: false

      t.timestamps
    end
    add_index :type_game_index, [ :type_id, :generation_id ], unique: true
    add_index :type_game_index, :generation_id

    create_table :type_name do |t|
      t.integer :type_id, null: false
      t.integer :local_language_id, null: false
      t.string :name, null: false

      t.timestamps
    end
    add_index :type_name, [ :type_id, :local_language_id ], unique: true
    add_index :type_name, :local_language_id
  end
end
