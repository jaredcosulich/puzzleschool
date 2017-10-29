class CreateCodePuzzleForm < ActiveRecord::Migration[5.1]
  def change
    create_table :code_puzzle_forms do |t|
      t.string :name
      t.string :email
      t.integer :source
      t.integer :payment
      t.string :code
      t.integer :access_count, default: 0
      t.timestamp :last_accessed_at
    end
  end
end
