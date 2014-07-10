class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.belongs_to :sale, index: true
      t.string :stripe_id
      t.belongs_to :board
      t.integer :amount
      t.string :plan
      t.string :state
      t.belongs_to :user
      t.string :state
      t.datetime :paid_until
      t.datetime :paid_at

      t.timestamps
    end
  end
end
