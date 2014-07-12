class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
      t.belongs_to :sale
      t.string :stripe_id
      t.references :actionee, polymorphic: true
      t.references :actioner, polymorphic: true
      t.integer :amount, :default => 0
      t.string :state, :default => "charged"

      t.timestamps
    end
  end
end