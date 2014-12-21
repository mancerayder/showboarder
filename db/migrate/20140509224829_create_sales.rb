class CreateSales < ActiveRecord::Migration
  def change
    create_table :sales do |t|
      t.references :actioner, polymorphic: true
      t.references :actionee, polymorphic: true
      t.string :stripe_token
      t.text :error
      t.integer :coupon_id
      t.integer :affiliate_id
      t.string :guid
      t.string :state
      t.string :plan

      t.timestamps
    end
    add_index :sales, [:actioner_id, :actioner_type]
    add_index :sales, [:actionee_id, :actionee_type]
  end
end
