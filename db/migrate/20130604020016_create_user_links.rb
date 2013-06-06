class CreateUserLinks < ActiveRecord::Migration
  def change
    create_table :user_links do |t|
      t.string :Category
      t.string :url
      t.string :ip
      t.string :location
      t.integer :is_friend

      t.timestamps
    end
  end
end
