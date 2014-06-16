class AddFacebookInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :facebook_nickname, :string
    add_column :users, :facebook_email, :string
    add_column :users, :facebook_image, :string
    add_column :users, :facebook_location, :string
    add_column :users, :facebook_url, :string    
    add_column :users, :timezone, :integer
  end
end