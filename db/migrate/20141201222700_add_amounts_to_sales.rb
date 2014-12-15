class AddAmountsToSales < ActiveRecord::Migration
  def change
      add_column :sales, :am_base, :decimal, :precision => 8, :scale => 2 # am is amount
      add_column :sales, :am_added, :decimal, :precision => 8, :scale => 2
      add_column :sales, :am_tip, :decimal, :precision => 8, :scale => 2
      add_column :sales, :am_sb, :decimal, :precision => 8, :scale => 2
      add_column :sales, :am_charity, :decimal, :precision => 8, :scale => 2
  end
end
