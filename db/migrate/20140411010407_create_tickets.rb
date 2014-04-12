class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.string :token, unique: true
      t.references :ticket_owner, polymorphic: true
      t.belongs_to :show, index: true
      t.string :state, default: "open"
      t.string :tier
      t.string :seat
      t.string :buy_method
      t.string :claim_method
      t.datetime :reserved_at
      t.datetime :bought_at
      t.datetime :canceled_at
      t.decimal :price, :precision => 8, :scale => 2
      t.belongs_to :referral_band, index: true

      t.timestamps
    end
    add_index :tickets, [:show_id, :reserved_at]
  end
end
