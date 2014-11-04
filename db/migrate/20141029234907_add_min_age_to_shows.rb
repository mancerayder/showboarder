class AddMinAgeToShows < ActiveRecord::Migration
  def change
    add_column :shows, :min_age, :string, :default => "All ages"
  end
end
