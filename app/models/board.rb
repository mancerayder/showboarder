class Board < ActiveRecord::Base
  has_many :show_boards
  has_many :users, through: :show_boards
end
