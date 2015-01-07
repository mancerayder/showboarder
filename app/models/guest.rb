class Guest < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true,
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_many :tickets, as: :ticket_owner
  has_many :sales, as: :actioner
  has_many :email_subscriptions, :as => :email_subscriber
  has_many :email_subscribeds, :through => :email_subscriptions, source: :board

  def email_subscribe(board)
    if email_subscriptions.find_by(board_id: board.id, email: email)
    	# do nothing
    else
      email_subscriptions.create(board_id: board.id, email_subscriber_type: "User", email_subscriber_id: id, email: email)
    end
  end
end
