class CreateShows < ActiveRecord::Migration
  def change
    create_table :shows do |t|
      t.boolean :confirmed
      t.datetime :date
      t.datetime :announce_date
      t.datetime :door_time
      t.datetime :show_time
      t.float :price_adv
      t.float :price_door
      t.integer :age_min

      t.timestamps
    end
  end
end
