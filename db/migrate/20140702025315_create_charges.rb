class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
      t.belongs_to :sale
      t.string :stripe_id
      t.references :actionee, polymorphic: true
      t.references :actioner, polymorphic: true
      t.string :state, :default => "charged"

      t.timestamps
    end

    add_index :charges, :sale_id
    add_index :charges, [:actionee_id, :actionee_type]
    add_index :charges, [:actioner_id, :actioner_type]
  end
end