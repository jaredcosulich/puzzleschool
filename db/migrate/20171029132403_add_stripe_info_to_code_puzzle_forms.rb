class AddStripeInfoToCodePuzzleForms < ActiveRecord::Migration[5.1]
  def change
    add_column :code_puzzle_forms, :stripe_customer_id, :string
    add_column :code_puzzle_forms, :stripe_charge_id, :string
  end
end
