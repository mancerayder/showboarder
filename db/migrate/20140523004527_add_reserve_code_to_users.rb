class AddReserveCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :reserve_code, :string
    add_column :users, :reserve_show, :integer
  end
end