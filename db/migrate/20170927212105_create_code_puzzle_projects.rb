class CreateCodePuzzleProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :code_puzzle_projects do |t|
      t.string :name
      t.integer :code_puzzle_class_id

      t.timestamps
    end
  end
end
