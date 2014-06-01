class CreateCarts < ActiveRecord::Migration
  def change
    create_table :carts do |t|
      t.string :reserve_code, default: ""
      t.timestamps
    end
  end
end
