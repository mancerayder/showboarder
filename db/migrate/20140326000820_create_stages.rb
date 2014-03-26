class CreateStages < ActiveRecord::Migration
  def change
    create_table :stages do |t|
      t.string :name
      t.integer :board_id
      t.integer :capacity

      t.timestamps
    end
  end
end
