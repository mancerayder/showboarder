class CreateActs < ActiveRecord::Migration
  def change
    create_table :acts do |t|
      t.string :musicbrainz_id
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
