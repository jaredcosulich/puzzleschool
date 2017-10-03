class CreateCodePuzzleCards < ActiveRecord::Migration[5.1]
  def change
    create_table :code_puzzle_cards do |t|
      t.string :photo_url
      t.string :code
      t.string :param
      t.integer :position
      t.integer :code_puzzle_group_id

      t.timestamps
    end
  end
end
