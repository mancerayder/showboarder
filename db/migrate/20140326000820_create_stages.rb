class CreateStages < ActiveRecord::Migration
  def change
    create_table :stages do |t|
      t.string :name
      t.belongs_to :board
      t.integer :capacity
      t.string :places_reference

      t.timestamps
    end
  end
end
