class CreateSubscribers < ActiveRecord::Migration[4.2]
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
