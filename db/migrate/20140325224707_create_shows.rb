class CreateShows < ActiveRecord::Migration
  def change
    create_table :shows do |t|
      t.integer :board_id
      t.boolean :confirmed

      t.timestamps
    end
  end
end
