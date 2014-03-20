class CreateUserBoards < ActiveRecord::Migration
  def change
    create_table :user_boards do |t|
      t.integer :boarder_id
      t.integer :board_id
      t.string :role, :null => false, :default => ""

      t.timestamps
    end
    add_index :user_boards, :boarder_id
    add_index :user_boards, :board_id
    add_index :user_boards, [:boarder_id, :board_id], unique: true
  end
end
