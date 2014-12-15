class AddStripeInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :stripe_scope, :string
    add_column :users, :stripe_livemode, :boolean
    add_column :users, :stripe_publishable_key, :string
    add_column :users, :stripe_token, :string    
    add_column :users, :stripe_token_type, :string
    add_column :users, :stripe_recipient_id, :string
    add_column :users, :stripe_recipient_email, :string
  end
end

