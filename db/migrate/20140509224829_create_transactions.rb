class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.references :actioner, polymorphic: true
      t.references :actionee, polymorphic: true
      t.string :state_before
      t.string :state_after      
      t.string :error

      t.timestamps
    end
  end
end
