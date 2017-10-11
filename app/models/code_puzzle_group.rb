class CodePuzzleGroup < ApplicationRecord

  belongs_to :code_puzzle_project
  has_many :code_puzzle_cards

end
