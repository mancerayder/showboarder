class AddReserveCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :reserve_code, :string
  end
end