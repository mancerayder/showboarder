class AddFacebookInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :nickname, :string
    add_column :users, :name, :string
    add_column :users, :image, :string
    add_column :users, :location, :string
    add_column :users, :facebook_url, :string    
    add_column :users, :timezone, :integer
  end
end
