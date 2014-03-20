class UserBoard < ActiveRecord::Base
  belongs_to :boarder, class_name: "User"
  belongs_to :board, class_name: "Board"
  validates_inclusion_of :role, in: %w( owner admin staff ), message: "role %{value} is not predefined"
  validates :board_id, presence: true
  validates :boarder_id, presence: true
end
