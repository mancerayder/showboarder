class Board < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true,
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  before_save { self.email = email.downcase }                    
  validates :vanity_url, presence: true, length: { maximum: 40 }
  validates :board_id, presence: true
  has_many :user_board, foreign_key: "boarder_id"
  has_many :reverse_relationships, foreign_key: "boarder_id",
                                   class_name:  "UserBoard"
  has_many :boarders, through: :reverse_relationships, source: :boarder
  has_many :shows, dependent: :destroy
  has_many :stages, dependent: :destroy
  has_many :pictures, dependent: :destroy


  def boarder!(user, role)
    user_board.create!(boarder_id: user.id, role: role)
  end

  def boarder?(user)
    user_board.find_by(boarder_id: user.id)
  end

  def role?(user)
    user_board.find_by(boarder_id: user.id).role
  end

  def is_owner?(user)
    user_board.find_by(boarder_id: user.id).role.eql?("owner")
  end

  def is_admin?(user)
    user_board.find_by(boarder_id: user.id).role.eql?("admin")
  end

  def is_staff?(user)
    user_board.find_by(boarder_id: user.id).role.eql?("staff")
  end    
end
