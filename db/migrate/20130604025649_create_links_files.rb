class CreateLinksFiles < ActiveRecord::Migration
  def change
    create_table :links_files do |t|
      t.attachment :attachment
      t.datetime :applied_at

      t.timestamps
    end
  end
end
