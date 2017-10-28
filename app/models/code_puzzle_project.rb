class CodePuzzleProject < ApplicationRecord

  belongs_to :code_puzzle_class
  has_many :code_puzzle_groups

  validates :title, presence: true

end