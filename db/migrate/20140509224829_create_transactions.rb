class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.references :actioner, polymorphic: true
      t.references :actionee, polymorphic: true
      t.string :state_before
      t.string :state_after      
      t.string :error
      t.string :stripe_id
      t.string :stripe_token
      t.text :error
      t.integer :amount
      t.integer :fee_amount
      t.integer :coupon_id
      t.integer :affiliate_id
      t.text :customer_address

      t.timestamps
    end
    add_index :transactions, [:actioner_id, :actioner_type, :created_at]
  end
end
