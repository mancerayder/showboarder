class AddErrorToCards < ActiveRecord::Migration
  def change
    add_column :cards, :error, :string
  end
end
