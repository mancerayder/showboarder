class CreateShows < ActiveRecord::Migration
  def change
    create_table :shows do |t|
      t.integer :board_id
      t.integer :stage_id
      t.string :state
      t.datetime :datetime_announce
      t.datetime :datetime_door
      t.datetime :datetime_show
      t.decimal :price_adv, :precision => 8, :scale => 2
      t.decimal :price_door, :precision => 8, :scale => 2
      t.boolean :pwyw, :null => false, :default => false
      t.boolean :for_sale

      t.timestamps
    end

    add_index :shows, [:board_id, :datetime_show]
    add_index :shows, [:stage_id, :datetime_show]
    add_index :shows, :board_id
    add_index :shows, :stage_id
  end
end
