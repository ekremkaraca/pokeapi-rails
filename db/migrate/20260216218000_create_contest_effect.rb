class CreateContestEffect < ActiveRecord::Migration[8.1]
  def change
    create_table :contest_effect do |t|
      t.integer :appeal
      t.integer :jam

      t.timestamps
    end
  end
end
