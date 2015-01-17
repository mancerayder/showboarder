class AddCategoryToShows < ActiveRecord::Migration
  def change
    add_column :shows, :category, :string, :default => ""
  end
end
