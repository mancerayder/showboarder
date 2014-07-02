class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
      t.belongs_to :transaction
      t.string :stripe_id

      t.timestamps
    end
  end
end
