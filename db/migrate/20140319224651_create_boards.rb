class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.string :name, :null => false, :default=> ""
      t.string :email, :null => false, :default => ""
      t.datetime :remember_created_at
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string :unconfirmed_email
      t.integer :time_zone, :null => false, :default => 0
      t.string :vanity_url

      t.timestamps
    end

    add_index :boards, :email,               :unique => true
    add_index :boards, :confirmation_token,   :unique => true
    add_index :boards, :vanity_url, :unique => true
  end
end