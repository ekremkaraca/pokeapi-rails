class CreateNature < ActiveRecord::Migration[8.1]
  def change
    create_table :nature do |t|
      t.string :name, null: false
      t.integer :decreased_stat_id
      t.integer :increased_stat_id
      t.integer :hates_flavor_id
      t.integer :likes_flavor_id
      t.integer :game_index

      t.timestamps
    end

    add_index :nature, :name, unique: true
    add_index :nature, :decreased_stat_id
    add_index :nature, :increased_stat_id
    add_index :nature, :hates_flavor_id
    add_index :nature, :likes_flavor_id
    add_index :nature, :game_index
  end
end
