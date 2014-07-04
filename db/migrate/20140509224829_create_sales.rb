class CreateSales < ActiveRecord::Migration
  def change
    create_table :sales do |t|
      t.references :actioner, polymorphic: true
      t.references :actionee, polymorphic: true
      # t.string :state_before
      # t.string :state_after      
      t.string :error
      t.string :stripe_id
      t.string :stripe_token
      t.string :stripe_token_type
      t.text :error
      t.integer :fee_amount
      t.integer :coupon_id
      t.integer :affiliate_id
      t.text :customer_address
      t.string :guid
      t.string :state
      t.string :plan
      t.string :stripe_subscription_id

      t.timestamps
    end
  end
end
