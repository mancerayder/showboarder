class User < ActiveRecord::Base
  before_save { email.downcase! }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true,
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :role, presence: true
  validates_inclusion_of :role, in: %w( test beta guest customer member admin ), message: "role %{value} is not predefined"
  has_secure_password validations: false

  with_options unless: :beta_or_guest? do |beta_or_guest|
    beta_or_guest.validates :name, presence: true, length: { minimum: 4, maximum: 30 }
    beta_or_guest.validates :password, presence: true, length: { minimum: 6, maximum: 50}
    beta_or_guest.validates_confirmation_of :password, :if => lambda { |m| m.password.present? }
    beta_or_guest.validates_presence_of     :password, :on => :create
    beta_or_guest.validates_presence_of     :password_confirmation, :if => lambda { |m| m.password.present? }
    beta_or_guest.before_create { |r| raise "Password digest missing on new record" if r.password_digest.blank? }
  end

  def beta_or_guest?
    role == "guest" || role == "beta"
  end
end