class Card < ActiveRecord::Base
  belongs_to :user

  validates_uniqueness_of :guid
  before_save :populate_guid

  def to_param
    guid
  end

  include AASM

  aasm column: 'state', skip_validation_on_save: true do
    state :pending, initial: true
    state :processing
    state :confirmed
    state :errored
    state :expired

    event :process, after: :add_to_customer do
      transitions from: :pending, to: :processing
    end

    event :finish do
      transitions from: :processing, to: :confirmed
    end

    event :fail do
      transitions from: :processing, to: :errored
    end

    event :expire do
      transitions from: :confirmed, to: :expired
    end

    event :unexpire do
      transitions from: :expired, to: :confirmed
    end
  end  

  def default?
    if self.stripe_id == self.user.stripe_default_card
      return true
    else
      return false
    end
  end

  def add_to_customer
    begin
      customer = Stripe::Customer.retrieve(self.user.stripe_id)

      if added_card = customer.cards.create(:card => self.stripe_token)
        self.update(
          stripe_id: added_card.id,
          expiration: Date.new(added_card.exp_year, added_card.exp_month, 1),
          last4: added_card.last4,
          brand: added_card.type
          )

        self.finish!
      end

    rescue Stripe::StripeError => e
      self.update_attributes(error: e.message)
      self.fail!
    end    
  end

  def check_expiration
    if self.state == confirmed && self.expired?
      self.expire!
    end
  end

  def expired?
    if expiration >= Time.now
      return true
    else
      return false
    end
  end

  def update_expired
  end

  def send_expiration_email
  end

  def queue_job!
    CardsWorker.perform_async(guid)
  end

  def populate_guid
    if new_record?
      while !valid? || self.guid.nil?
        self.guid = SecureRandom.random_number(1_000_000_000_000_000_000).to_s(32)
      end
    end
  end  

  def image
    img = ""
    if brand == "visa"
      img = asset_path('visa.png')
    elsif brand == "mastercard"
      img = asset_path('mastercard.png')
    elsif brand == "discover"
      img = asset_path('discover.png')
    elsif brand == "amex"
      img = asset_path('amex.png')
    elsif brand == "dinersclub"
      img = asset_path('dinersclub.png')
    elsif brand == "maestro"
      img = asset_path('maestro.png')
    else
      img = asset_path('laser.png')
    end
    return img
  end
end