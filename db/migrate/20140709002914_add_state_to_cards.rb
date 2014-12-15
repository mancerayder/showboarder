class AddStateToCards < ActiveRecord::Migration
  def change
    add_column :cards, :state, :string
  end
end
