class CreateActs < ActiveRecord::Migration
  def change
    create_table :acts do |t|
      t.string :musicbrainz_id
      t.string :name
      t.string :email
      t.string :link_main
      t.string :link_youtube
      t.string :link_twitter
      t.string :link_facebook
      t.string :link_soundcloud
      t.string :link_bandcamp

      t.timestamps
    end
  end
end
