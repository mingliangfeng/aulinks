class CreateLinkRelations < ActiveRecord::Migration
  def change
    create_table :link_relations do |t|
      t.integer :parent_id
      t.integer :sub_id
      t.integer :show_order

      t.timestamps
    end
  end
end
