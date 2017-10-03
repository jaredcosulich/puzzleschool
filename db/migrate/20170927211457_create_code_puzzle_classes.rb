class CreateCodePuzzleClasses < ActiveRecord::Migration[5.1]
  def change
    create_table :code_puzzle_classes do |t|
      t.string :name
      t.string :slug, :uniq
      t.boolean :active

      t.timestamps
    end
  end
end
