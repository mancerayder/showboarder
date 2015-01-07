class AddEmailToEmailSubscriptions < ActiveRecord::Migration
  def change
    add_column :email_subscriptions, :email, :string
  end
end
