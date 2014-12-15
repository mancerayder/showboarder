class AddGuidToCards < ActiveRecord::Migration
  def change
    add_column :cards, :guid, :string
  end
end
