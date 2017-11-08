class CodePuzzleCard < ApplicationRecord

  belongs_to :code_puzzle_group

  CARDS = [
    ["A1", "Move Forward"],
    ["A2", "Move Backward"],
    ["A3", "Rotate Right"],
    ["A4", "Rotate Left"],
    ["A5", "Fill Color"],
    ["P1", "Pen Up"],
    ["P2", "Pen Down"],
    ["P3", "Pen Size"],
    ["P4", "Pen Color"],
    ["F1", "Function"],
    ["F2", "End Function"],
    ["L1", "Loop"],
    ["L2", "End Loop"]
  ]

  default_scope { order(position: :asc) }
end
