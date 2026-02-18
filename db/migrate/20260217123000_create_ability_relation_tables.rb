class CreateAbilityRelationTables < ActiveRecord::Migration[8.1]
  def change
    create_table :ability_name do |t|
      t.integer :ability_id, null: false
      t.integer :local_language_id, null: false
      t.string :name, null: false

      t.timestamps
    end
    add_index :ability_name, :ability_id
    add_index :ability_name, :local_language_id
    add_index :ability_name, [ :ability_id, :local_language_id ], name: "idx_ability_name_lookup"

    create_table :ability_prose do |t|
      t.integer :ability_id, null: false
      t.integer :local_language_id, null: false
      t.text :short_effect
      t.text :effect

      t.timestamps
    end
    add_index :ability_prose, [ :ability_id, :local_language_id ], unique: true
    add_index :ability_prose, :local_language_id

    create_table :ability_changelog do |t|
      t.integer :ability_id, null: false
      t.integer :changed_in_version_group_id, null: false

      t.timestamps
    end
    add_index :ability_changelog, :ability_id
    add_index :ability_changelog, :changed_in_version_group_id

    create_table :ability_changelog_prose do |t|
      t.integer :ability_changelog_id, null: false
      t.integer :local_language_id, null: false
      t.text :effect

      t.timestamps
    end
    add_index :ability_changelog_prose, [ :ability_changelog_id, :local_language_id ], unique: true, name: "idx_ability_changelog_prose_unique"
    add_index :ability_changelog_prose, :local_language_id

    create_table :ability_flavor_text do |t|
      t.integer :ability_id, null: false
      t.integer :version_group_id, null: false
      t.integer :language_id, null: false
      t.text :flavor_text

      t.timestamps
    end
    add_index :ability_flavor_text, :ability_id
    add_index :ability_flavor_text, :version_group_id
    add_index :ability_flavor_text, :language_id
    add_index :ability_flavor_text, [ :ability_id, :version_group_id, :language_id ], name: "idx_ability_flavor_text_lookup"
  end
end
