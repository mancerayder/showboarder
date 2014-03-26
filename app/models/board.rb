class Board < ActiveRecord::Base
  has_many :user_boards, foreign_key: "board_id", dependent: :destroy
  has_many :boarders, through: :user_boards, source: :boarder
  has_many :stages
  has_many :shows

  # has_many :reverse_user_boards, foreign_key: "board_id",
  #                                  class_name:  "UserBoard",
  #                                  dependent:   :destroy
  # has_many :boarders, through: :reverse_user_boards, source: :boarder  
end
