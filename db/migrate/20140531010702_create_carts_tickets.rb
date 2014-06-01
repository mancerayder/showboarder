class CreateCartsTickets < ActiveRecord::Migration
  def change
    create_table :carts_tickets, id: false do |t|
      t.belongs_to :cart
      t.belongs_to :ticket
    end
  end
end
