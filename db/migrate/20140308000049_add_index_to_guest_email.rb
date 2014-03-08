class AddIndexToGuestEmail < ActiveRecord::Migration
  def change
    add_index :guests, :email, unique: true
  end
end
