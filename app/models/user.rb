class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
  devise :omniauthable, :omniauth_providers => [:facebook, :stripe_connect]
  has_many :user_boards, foreign_key: "boarder_id", dependent: :destroy
  has_many :boards, through: :user_boards, source: :board
  has_many :tickets, as: :ticket_owner
  has_many :sales, as: :actioner

  attr_accessor :login

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    if user = User.where(:email => auth.info.email).first
      user.update_attributes(
        facebook_email:auth.info.email,
        name:auth.info.name,
        provider:auth.provider,
        facebook_url:auth.info.urls.Facebook,
        facebook_uid:auth.uid,
        facebook_image:auth.info.image,
        facebook_nickname:auth.info.nickname,
        location:auth.info.location)
      user
    else
      user = User.create(name:auth.info.name,
        facebook_email:auth.info.email,
        provider:auth.provider,
        facebook_url:auth.info.urls.Facebook,
        facebook_uid:auth.uid,
        email:auth.info.email,
        facebook_image:auth.info.image,
        facebook_nickname:auth.info.nickname,
        facebook_location:auth.info.location,
        password:Devise.friendly_token[0,20])
      user
    end
  end

  def self.find_for_stripe_oauth(auth, signed_in_resource)
    puts "froop33"
    puts auth.to_yaml
    signed_in_resource.update_attributes(
      stripe_recipient_id:auth.uid,
      stripe_scope:auth.info.scope,
      stripe_livemode:auth.info.livemode,
      stripe_publishable_key:auth.info.stripe_publishable_key,
      stripe_access_key:auth.credentials.token,
      stripe_token_type:auth.extra.raw_info.token_type
      )
    signed_in_resource
  end

  def boarder!(board, role)
    user_boards.create(board_id: board.id, role: role)
  end

  def unboard!(board)
    user_boards.find_by(board_id: board.id).destroy
  end

  def boarder?(board)
    user_boards.find_by(board_id: board.id)
  end

  def board_role(board)
    user_boards.find_by(board_id: board.id).role
  end

  def board_role_assign(board, role)
    user_boards.find_by(board_id: board.id).update(role: role)
  end

  def tickets_reserved_assign
    if self.reserve_code?
      cart = Cart.find_by_reserve_code(self.reserve_code)
      cart.tickets.each do |t|
        if t && !t.expired?
          t.owner(self)
        elsif t
          t.make_open("Reservation expired before state change")
        else
          next
        end
      end
      self.update(reserve_code:nil)
    end
  end

  # def self.find_first_by_auth_conditions(warden_conditions)
  #   conditions = warden_conditions.dup
  #   if login = conditions.delete(:login)
  #     where(conditions).where(["lower(name) = :value OR lower(email) = :value", { :value => login.downcase }]).first
  #   else
  #     where(conditions).first
  #   end
  # end

  # validates :name, presence: true, unique: true, length: { minimum: 4, maximum: 20 }
  # before_save { email.downcase! }
  # VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  # validates :email, presence:   true,
  #                   format:     { with: VALID_EMAIL_REGEX },
  #                   uniqueness: { case_sensitive: false }
  # validates_inclusion_of :role, in: %w( test beta guest customer member admin ), message: "role %{value} is not predefined"
  # has_secure_password validations: false

  # with_options unless: :beta_or_guest? do |beta_or_guest|
  #   beta_or_guest.validates :name, presence: true, unique: true, length: { minimum: 4, maximum: 20 }
  #   beta_or_guest.validates :password, presence: true, length: { minimum: 6, maximum: 50}
  #   beta_or_guest.validates_confirmation_of :password, :if => lambda { |m| m.password.present? }
  #   beta_or_guest.validates_presence_of     :password, :on => :create
  #   beta_or_guest.validates_presence_of     :password_confirmation, :if => lambda { |m| m.password.present? }
  #   beta_or_guest.before_create { |r| raise "Password digest missing on new record" if r.password_digest.blank? }
  # end

  # def beta_or_guest?
  #   role == "guest" || role == "beta"
  # end
end