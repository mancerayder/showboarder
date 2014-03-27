class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.string :name
      t.string :vanity_url, presence: true, uniqueness: { case_sensitive: false }
      t.timestamps
    end
  end
end