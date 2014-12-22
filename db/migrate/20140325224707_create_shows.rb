class CreateShows < ActiveRecord::Migration
  def change
    create_table :shows do |t|
      t.belongs_to :board
      t.belongs_to :stage
      t.string :state
      t.string :error
      t.datetime :announce_at
      t.datetime :door_at
      t.datetime :show_at
      t.decimal :price_adv, :precision => 8, :scale => 2
      t.decimal :price_door, :precision => 8, :scale => 2
      t.string :ticketing_type, :default => "none"
      t.integer :custom_capacity
      t.integer :payer_id
      t.datetime :paid_at

      t.timestamps
    end

    add_index :shows, :board_id
    add_index :shows, :stage_id
  end
end
