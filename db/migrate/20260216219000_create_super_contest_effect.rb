class CreateSuperContestEffect < ActiveRecord::Migration[8.1]
  def change
    create_table :super_contest_effect do |t|
      t.integer :appeal

      t.timestamps
    end
  end
end
