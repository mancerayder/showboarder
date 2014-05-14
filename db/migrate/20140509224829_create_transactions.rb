class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.references :actioner, polymorphic: true
      t.text :ticket_ids
      t.string :state_before
      t.string :state_after      
      t.string :error

      t.timestamps
    end
    add_index :transactions, [:actioner_id, :actioner_type, :created_at]
  end
end
