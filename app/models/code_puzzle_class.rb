class CodePuzzleClass < ApplicationRecord

  has_many :code_puzzle_projects

  include FriendlyId
  friendly_id :generated_slug, use: :slugged

  def generated_slug
    options = [*("a".."z"),*("A".."Z"),*(0..9)].compact
    id_parts = id.to_s.split.map { |i| options[i.to_i] }.join
    "#{options.sample}#{options.sample}#{id_parts}#{options.sample}"
  end

end
