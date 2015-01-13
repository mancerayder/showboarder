class AddStripeIdToGuests < ActiveRecord::Migration
  def change
    add_column :guests, :stripe_id, :string
  end
end
