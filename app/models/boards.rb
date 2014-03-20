class Boards < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true,
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  before_save { self.email = email.downcase }                    
  validates :vanity_url, presence: true, length: { maximum: 40 }
  validates :board_id, presence: true
end
