class AddStripeRememberCardToSales < ActiveRecord::Migration
  def change
    add_column :sales, :stripe_remember_card, :boolean
  end
end
