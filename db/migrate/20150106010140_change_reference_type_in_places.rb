class ChangeReferenceTypeInPlaces < ActiveRecord::Migration
  def change
    change_column :places, :reference, :text
  end
end
