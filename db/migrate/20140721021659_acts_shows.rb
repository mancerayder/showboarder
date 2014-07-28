class ActsShows < ActiveRecord::Migration
  def change
    create_table :acts_shows, id: false do |t|
      t.belongs_to :show
      t.belongs_to :act
    end
  end
end
