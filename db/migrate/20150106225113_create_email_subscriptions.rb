class CreateEmailSubscriptions < ActiveRecord::Migration
  def change
    create_table :email_subscriptions do |t|
      t.integer :email_subscriber_id
      t.string :email_subscriber_type
      t.integer :board_id

      t.timestamps
    end
  end
end
