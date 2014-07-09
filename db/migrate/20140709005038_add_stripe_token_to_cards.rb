class AddStripeTokenToCards < ActiveRecord::Migration
  def change
    add_column :cards, :stripe_token, :string
  end
end
