class AddGuidToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :guid, :string
  end
end
