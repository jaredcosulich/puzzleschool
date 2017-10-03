class ChangeCodePuzzleProjectNameToTitle < ActiveRecord::Migration[5.1]
  def change
    rename_column :code_puzzle_projects, :name, :title
  end
end
