class CreateCategoryRelations < ActiveRecord::Migration
  def change
    create_table :category_relations do |t|
      t.integer :parent_id
      t.integer :sub_id
      t.integer :related
      t.integer :show_order

      t.timestamps
    end
  end
end
