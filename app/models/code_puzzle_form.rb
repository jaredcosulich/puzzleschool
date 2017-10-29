class CodePuzzleForm < ApplicationRecord

  include FriendlyId
  friendly_id :slug_candidates, use: :slugged, slug_column: :code

  enum source: [ :at_home, :school, :afterschool, :homeschool, :just_curious, :other ]
  PAYMENT_OPTIONS = [
    ["I'm sorry, I can't afford to contribute now.", -1],
    ["$0.75", 75],
    ["$1.50", 150],
    ["$2.00", 200],
    ["$3.00", 300],
    ["$4.00", 400],
    ["$5.00", 600],
    ["$6.00", 700],
    ["$7.00", 800],
    ["$8.00", 800],
    ["$9.00", 900],
    ["$10.00", 1000],
    ["$15.00", 1500],
    ["$20.00", 2000],
    ["$25.00", 2500],
    ["$40.00", 4000],
    ["$60.00", 6000],
    ["$80.00", 8000],
    ["$100.00", 10000]
  ]

  private

    def slug_candidates
      letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".split('')
      id_string = id.to_s.split.map { |n| letters[n] }.join('')
      [ "#{letters.sample}#{letters.sample}#{id_string}#{letters.sample}#{letters.sample}" ]
    end

end
