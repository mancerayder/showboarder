class CreateShows < ActiveRecord::Migration
  def change
    create_table :shows do |t|
      t.belongs_to :board
      t.belongs_to :stage
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
  end
end
