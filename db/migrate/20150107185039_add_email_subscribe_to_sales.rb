class AddEmailSubscribeToSales < ActiveRecord::Migration
  def change
    add_column :sales, :email_subscribe, :boolean, default: false
  end
end
