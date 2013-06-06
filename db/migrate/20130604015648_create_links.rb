class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :name
      t.string :title
      t.string :url
      t.string :favicon
      t.string :info

      t.timestamps
    end
  end
end
