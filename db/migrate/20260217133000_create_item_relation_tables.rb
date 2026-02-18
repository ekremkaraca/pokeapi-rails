class CreateItemRelationTables < ActiveRecord::Migration[8.1]
  def change
    create_table :item_flag_map do |t|
      t.integer :item_id, null: false
      t.integer :item_flag_id, null: false

      t.timestamps
    end
    add_index :item_flag_map, [ :item_id, :item_flag_id ], unique: true
    add_index :item_flag_map, :item_flag_id

    create_table :item_prose do |t|
      t.integer :item_id, null: false
      t.integer :local_language_id, null: false
      t.text :short_effect
      t.text :effect

      t.timestamps
    end
    add_index :item_prose, [ :item_id, :local_language_id ], unique: true
    add_index :item_prose, :local_language_id

    create_table :item_flavor_text do |t|
      t.integer :item_id, null: false
      t.integer :version_group_id, null: false
      t.integer :language_id, null: false
      t.text :flavor_text

      t.timestamps
    end
    add_index :item_flavor_text, [ :item_id, :version_group_id, :language_id ], unique: true, name: "idx_item_flavor_text_unique"
    add_index :item_flavor_text, :language_id
    add_index :item_flavor_text, :version_group_id

    create_table :item_game_index do |t|
      t.integer :item_id, null: false
      t.integer :generation_id, null: false
      t.integer :game_index, null: false

      t.timestamps
    end
    add_index :item_game_index, [ :item_id, :generation_id ], unique: true
    add_index :item_game_index, :generation_id

    create_table :item_name do |t|
      t.integer :item_id, null: false
      t.integer :local_language_id, null: false
      t.string :name, null: false

      t.timestamps
    end
    add_index :item_name, [ :item_id, :local_language_id ], unique: true
    add_index :item_name, :local_language_id
  end
end
