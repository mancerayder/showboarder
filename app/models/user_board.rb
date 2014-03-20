class UserBoard < ActiveRecord::Base
  belongs_to :user, class_name: "User"
  belongs_to :board, class_name: "Board"
  validates_inclusion_of :role, in: %w( owner admin staff ), message: "role %{value} is not predefined"
  validates :board_id, presence: true
  validates :user_id, presence: true
end
