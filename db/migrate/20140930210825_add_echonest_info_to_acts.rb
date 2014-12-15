class AddEchonestInfoToActs < ActiveRecord::Migration
  def change
    add_column :acts, :echonest_id, :string
  end
end
