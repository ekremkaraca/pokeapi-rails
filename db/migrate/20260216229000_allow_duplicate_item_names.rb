class AllowDuplicateItemNames < ActiveRecord::Migration[8.1]
  def change
    remove_index :item, :name
    add_index :item, :name
  end
end
