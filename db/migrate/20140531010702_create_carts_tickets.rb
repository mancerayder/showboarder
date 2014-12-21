class CreateCartsTickets < ActiveRecord::Migration
  def change
    create_table :carts_tickets, id: false do |t|
      t.belongs_to :cart
      t.belongs_to :ticket
    end

    add_index :carts_tickets, :cart_id
    add_index :carts_tickets, :ticket_id
  end
end
