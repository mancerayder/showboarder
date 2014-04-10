class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.string :name
      t.string :state, presence: true, null: false, default: "private"
      t.string :vanity_url, presence: true, uniqueness: { case_sensitive: false }
      t.string :email
      t.string :phone
      t.integer :paid_tier
      t.datetime :paid_at

      t.timestamps
    end
  end
end