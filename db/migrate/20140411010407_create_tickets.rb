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
      t.decimal :price, :precision => 8, :scale => 2
      t.belongs_to :referral_band, index: true
      t.string :reserve_code, default: ""
      t.date :reserved_at

      t.timestamps
    end

    add_index :tickets, [:show_id, :reserve_code]
  end
end
