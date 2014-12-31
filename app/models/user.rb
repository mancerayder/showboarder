class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :async,
         :recoverable, :rememberable, :trackable, :validatable #, :confirmable
  devise :omniauthable, :omniauth_providers => [:stripe_connect] #:facebook, 
  has_many :user_boards, foreign_key: "boarder_id", dependent: :destroy
  has_many :boards, through: :user_boards, source: :board
  has_many :tickets, as: :ticket_owner
  has_many :sales, as: :actioner
  has_many :charges, as: :actioner

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
        # location:auth.info.location,
        facebook_nickname:auth.info.nickname
        )
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
        # facebook_location:auth.info.location,
        password:Devise.friendly_token[0,20])
      AdminMailer.delay.new_user(user.id)
      user
    end
  end

  def self.find_for_stripe_oauth(auth, signed_in_resource)
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

  def tickets_clear_expired_reservations
    reserved = Ticket.where(ticket_owner_id:self.id, state:"reserved")
    reserved.each do |t|
      if t.expired?
        t.make_open
      end
    end
  end

  def tickets_reserved_assign(reserve_code)
    assigned_count = 0
    if cart = Cart.find_by_reserve_code(reserve_code)
      cart.tickets.each do |t|
        if t && !t.expired?
          t.owner(self)
          assigned_count +=1
        elsif t
          t.make_open("Reservation expired before state change")
        else
          next
        end
      end
    end
  end

  def tickets_retrieve_and_clear_expired
    tickets = []
    self.tickets.each do |t|
      if t && t.expired?
        t.make_open
      elsif t
        tickets << t
      else
        next
      end
    end
    return tickets
  end

  def cards_sorted
    cards_sorted = []
    self.cards.each do |c|
      if c.stripe_id == self.stripe_default_card && ["confirmed", "expired"].include?(c.state)
        cards_sorted.unshift(c)
      elsif ["confirmed", "expired"].include?(c.state)
        cards_sorted << c
      end
    end
    cards_sorted
  end

  def default_card_return
    self.cards.where(stripe_id:self.stripe_default_card).first
  end

  def stripe_delete_all_cards_but_default
    cus = self.stripe_customer_object
    cus.cards.each do |c|
      if c.id != self.stripe_default_card
        begin
          cus.cards.retrieve(c.id).delete()
        rescue => e
          puts e.to_s
        end
      end
    end
    cus.save
    self.cards.each do |c|
      if c.stripe_id != self.stripe_default_card
        c.destroy
      end
    end
  end

  def stripe_customer_object
    begin
      cus = Stripe::Customer.retrieve(self.stripe_id)
      return cus
    rescue => e
      puts e.to_s
    end
  end

  def tickets_by_show
    tbs = Hash.new { |hash, key| hash[key] = [] }
    self.tickets.each do |t|
      tbs[t.show] << t
    end
    return tbs
  end
end