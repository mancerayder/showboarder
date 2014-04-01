class Board < ActiveRecord::Base
  has_many :user_boards, foreign_key: "board_id", dependent: :destroy
  has_many :boarders, through: :user_boards, source: :boarder
  has_many :stages
  has_many :shows
  validates :vanity_url, presence: true, length: {minimum:4, maximum:30}
  before_save { self.vanity_url = vanity_url.downcase }
  validates_format_of :vanity_url, :with => /[-a-z0-9_.]/
  
  # has_many :reverse_user_boards, foreign_key: "board_id",
  #                                  class_name:  "UserBoard",
  #                                  dependent:   :destroy
  # has_many :boarders, through: :reverse_user_boards, source: :boarder  
  def to_param
    vanity_url
  end

  def boarder?(user)
    user_boards.find_by(boarder_id: user.id)
  end

  def board_role(user)
    user_boards.find_by(boarder_id: user.id).role
  end
end
