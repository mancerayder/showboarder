class CreateStages < ActiveRecord::Migration
  def change
    create_table :stages do |t|
      t.string :name
      t.belongs_to :board
      t.integer :capacity
      t.string :places_reference
      t.string :places_formatted_address_short
      t.text :places_json

      t.timestamps
    end

    add_index :stages, :board_id
  end
end
