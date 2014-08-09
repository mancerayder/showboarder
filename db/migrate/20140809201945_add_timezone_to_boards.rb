class AddTimezoneToBoards < ActiveRecord::Migration
  def change
    add_column :boards, :timezone, :string
  end
end
