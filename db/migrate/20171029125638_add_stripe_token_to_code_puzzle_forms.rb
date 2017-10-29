class AddStripeTokenToCodePuzzleForms < ActiveRecord::Migration[5.1]
  def change
    add_column :code_puzzle_forms, :stripe_token, :string
  end
end
