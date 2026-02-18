class CreateMoveRelationTables < ActiveRecord::Migration[8.1]
  def change
    create_table :contest_combo do |t|
      t.integer :first_move_id, null: false
      t.integer :second_move_id, null: false

      t.timestamps
    end
    add_index :contest_combo, [ :first_move_id, :second_move_id ], unique: true
    add_index :contest_combo, :second_move_id

    create_table :super_contest_combo do |t|
      t.integer :first_move_id, null: false
      t.integer :second_move_id, null: false

      t.timestamps
    end
    add_index :super_contest_combo, [ :first_move_id, :second_move_id ], unique: true
    add_index :super_contest_combo, :second_move_id

    create_table :move_effect_prose do |t|
      t.integer :move_effect_id, null: false
      t.integer :local_language_id, null: false
      t.text :short_effect
      t.text :effect

      t.timestamps
    end
    add_index :move_effect_prose, [ :move_effect_id, :local_language_id ], unique: true
    add_index :move_effect_prose, :local_language_id

    create_table :move_effect_changelog do |t|
      t.integer :effect_id, null: false
      t.integer :changed_in_version_group_id, null: false

      t.timestamps
    end
    add_index :move_effect_changelog, :effect_id
    add_index :move_effect_changelog, :changed_in_version_group_id

    create_table :move_effect_changelog_prose do |t|
      t.integer :move_effect_changelog_id, null: false
      t.integer :local_language_id, null: false
      t.text :effect

      t.timestamps
    end
    add_index :move_effect_changelog_prose, [ :move_effect_changelog_id, :local_language_id ], unique: true, name: "idx_move_effect_changelog_prose_unique"
    add_index :move_effect_changelog_prose, :local_language_id

    create_table :move_flavor_text do |t|
      t.integer :move_id, null: false
      t.integer :version_group_id, null: false
      t.integer :language_id, null: false
      t.text :flavor_text

      t.timestamps
    end
    add_index :move_flavor_text, :move_id
    add_index :move_flavor_text, :version_group_id
    add_index :move_flavor_text, :language_id
    add_index :move_flavor_text, [ :move_id, :version_group_id, :language_id ], name: "idx_move_flavor_text_lookup"

    create_table :move_meta do |t|
      t.integer :move_id, null: false
      t.integer :meta_category_id
      t.integer :meta_ailment_id
      t.integer :min_hits
      t.integer :max_hits
      t.integer :min_turns
      t.integer :max_turns
      t.integer :drain
      t.integer :healing
      t.integer :crit_rate
      t.integer :ailment_chance
      t.integer :flinch_chance
      t.integer :stat_chance

      t.timestamps
    end
    add_index :move_meta, :move_id, unique: true
    add_index :move_meta, :meta_category_id
    add_index :move_meta, :meta_ailment_id

    create_table :move_name do |t|
      t.integer :move_id, null: false
      t.integer :local_language_id, null: false
      t.string :name, null: false

      t.timestamps
    end
    add_index :move_name, [ :move_id, :local_language_id ], unique: true
    add_index :move_name, :local_language_id

    create_table :move_changelog do |t|
      t.integer :move_id, null: false
      t.integer :changed_in_version_group_id, null: false
      t.integer :type_id
      t.integer :power
      t.integer :pp
      t.integer :accuracy
      t.integer :priority
      t.integer :target_id
      t.integer :effect_id
      t.integer :effect_chance

      t.timestamps
    end
    add_index :move_changelog, [ :move_id, :changed_in_version_group_id ], unique: true, name: "idx_move_changelog_unique"
    add_index :move_changelog, :changed_in_version_group_id
    add_index :move_changelog, :type_id

    create_table :move_meta_stat_change do |t|
      t.integer :move_id, null: false
      t.integer :stat_id, null: false
      t.integer :change, null: false

      t.timestamps
    end
    add_index :move_meta_stat_change, [ :move_id, :stat_id, :change ], unique: true, name: "idx_move_meta_stat_change_unique"
    add_index :move_meta_stat_change, :stat_id
  end
end
