class CreateCategoryLinks < ActiveRecord::Migration
  def change
    create_table :category_links do |t|
      t.integer :category_id
      t.integer :link_id
      t.integer :recommend
      t.integer :show_order

      t.timestamps
    end
  end
end
