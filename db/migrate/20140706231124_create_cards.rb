class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.date :expiration
      t.string :brand
      t.string :last4
      t.string :stripe_id
      t.belongs_to :user

      t.timestamps
    end
  end
end
