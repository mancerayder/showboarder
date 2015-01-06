class ChangeGooglePlacesReferenceTypeInStages < ActiveRecord::Migration
  def change
    change_column :stages, :places_reference, :text
  end
end
