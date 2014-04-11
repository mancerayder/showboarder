class CreateShows < ActiveRecord::Migration
  def change
    create_table :shows do |t|
      t.belongs_to :board
      t.belongs_to :stage
      t.string :state
      t.datetime :announce_at
      t.datetime :door_at
      t.datetime :show_at
      t.decimal :price_adv, :precision => 8, :scale => 2
      t.decimal :price_door, :precision => 8, :scale => 2
      t.boolean :pwyw, :null => false, :default => false
      t.boolean :for_sale
      t.boolean :rsvp_only
      t.boolean :ticketed
      t.integer :custom_capacity
      t.integer :payer_id
      t.datetime :paid_at

      t.timestamps
    end
  end
end