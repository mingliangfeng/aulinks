class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.integer :hid
      t.string :name
      t.integer :is_top

      t.timestamps
    end
  end
end
