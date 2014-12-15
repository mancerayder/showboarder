class AddStripeDefaultCardToUsers < ActiveRecord::Migration
  def change
    add_column :users, :stripe_default_card, :string
  end
end
