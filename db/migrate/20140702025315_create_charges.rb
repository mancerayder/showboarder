class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
      t.belongs_to :sale
      t.string :stripe_id

      t.timestamps
    end
  end
end
