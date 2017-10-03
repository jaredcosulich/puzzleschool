class CreateCodePuzzleGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :code_puzzle_groups do |t|
      t.string :photo_url
      t.integer :position
      t.integer :code_puzzle_project_id

      t.timestamps
    end
  end
end
