class AddAmountsToCharges < ActiveRecord::Migration
  def change
    add_column :charges, :application_fee, :integer
    add_column :charges, :am_base, :integer
    add_column :charges, :am_charity, :integer
    add_column :charges, :am_sb, :integer
  end
end
