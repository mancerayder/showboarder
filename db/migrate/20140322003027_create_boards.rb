class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.string :name
      before_save { self.vanity_url = vanity_url.downcase }
      t.string :vanity_url, presence: true, uniqueness: { case_sensitive: false }
      validates_format_of :username, :with => /^[-a-z0-9_.]+$/


      t.timestamps
    end
  end
end
