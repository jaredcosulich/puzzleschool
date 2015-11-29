class CreateSubscribers < ActiveRecord::Migration
  def change
    create_table :subscribers do |t|
      t.string :name
      t.string :email
      t.string :zipcode
      t.integer :birthyear
      t.text :notes

      t.timestamps null: false
    end
  end
end
