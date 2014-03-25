class UserBoard < ActiveRecord::Base
  belongs_to :boarder, class_name: "User"
  belongs_to :board, class_name: "Board"
  validates :boarder_id, presence: true
  validates :board_id, presence: true
  validates :role, presence: true
end