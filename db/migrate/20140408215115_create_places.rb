class CreatePlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.string :formatted_address
      t.string :formatted_phone_number
      t.float :lat
      t.float :lng
      t.string :international_phone_number
      t.string :name
      t.text :opening_hours
      t.string :photo1
      t.string :photo2
      t.string :photo3
      t.string :photo4
      t.string :photo5
      t.integer :price_level
      t.float :rating
      t.integer :utc_offset
      t.string :vicinity
      t.string :website
      t.string :reference
      t.belongs_to :stage, index: true

      t.timestamps
    end
  end
end