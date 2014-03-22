class CreateUserBoards < ActiveRecord::Migration
  def change
    create_table :user_boards do |t|
      t.belongs_to :user
      t.belongs_to :board
      t.timestamps
    end
  end
end
