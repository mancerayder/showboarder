class Transaction < ActiveRecord::Base
  has_paper_trail

  belongs_to :actioner, polymorphic: true
  belongs_to :actionee, polymorphic: true

  validates_uniqueness_of :guid

  before_save :populate_guid  

  include AASM

  aasm column: 'state', skip_validation_on_save: true do
    state :pending, initial: true
    state :processing
    state :finished
    state :errored
    state :refunded

    event :process, after: :charge_card do
      transitions from: :pending, to: :processing
    end

    event :finish, after: :send_receipt do
      transitions from: :processing, to: :finished
    end

    event :fail do
      transitions from: :processing, to: :errored
    end

    event :refund, after: :send_refund_email do
      transitions from: :finished, to: :refunded
    end
  end

  def charge_card #new version
    save!
    begin
      if actioner.stripe_id?
        customer = Stripe::Customer.retrieve(actioner.stripe_id)
      else
        customer = Stripe::Customer.create(
          card: self.stripe_token,
          email: actioner.email,
          description: actionee.tickets.count.to_s + " ticket purchase" #maybe add more detail here
        )
        if actioner_type == "User"
          actioner.update(stripe_id:customer.id)
        end
      end
      charge = Stripe::Charge.create(
        customer: customer.id,
        amount: amount,
        currency: "usd",
        description: actionee.tickets.count.to_s + " ticket purchase" #maybe add more detail here
        )
    # if user_signed_in?
    #   if current_user.stripe_id
    #     customer = Stripe::Customer.retrieve(current_user.stripe_id)
    #     charge = Stripe::Charge.create(
    #       :customer => customer.id,
    #       :amount => @amount,
    #       :currency => "usd",
    #       :description => @show.id.to_s + " " + @quantity.to_s
    #       )
    #   else
    #     customer = Stripe::Customer.create(
    #       :card => token,
    #       :email => current_user.email,
    #       :description => "Single show ticketing - new"
    #       )
    #     charge = Stripe::Charge.create(
    #       :customer => customer.id,
    #       :amount => @amount,
    #       :currency => "usd",
    #       :description => @show.id.to_s + " " + @quantity.to_s
    #       )

    #     current_user.update_attributes(stripe_id:customer.id)
    #   end
    # else

    #   customer = Stripe::Customer.create(
    #       :card => token,
    #       :email => @buyer.email,
    #       :description => "Single show ticketing - new"
    #       )
    #     charge = Stripe::Charge.create(
    #       :customer => customer.id,
    #       :amount => @amount,
    #       :currency => "usd",
    #       :description => @cart.tickets.first.show.id.to_s + " " + @cart.tickets.count.to_s + " " + @buyer.id.to_s + " " + @buyer.class.to_s
    #       )
    # end

      actionee.tickets.each do |t|
        t.buy(@buyer)
      end
    end
  end

  # def charge_card #needs to be changed
  #   save!
  #   begin
  #     customer = Stripe::Customer.create(
  #       card: self.stripe_token,
  #       email: self.email
  #     )

  #     charge = Stripe::Charge.create(
  #       amount: self.amount,
  #       currency: "usd",
  #       customer: customer.id,
  #       description: self.guid,
  #     )

  #     if charge.respond_to?(:fee)
  #       fee = charge.fee
  #     else
  #       balance = Stripe::BalanceTransaction.retrieve(charge.balance_transaction)
  #       fee = balance.fee
  #     end

  #     self.update_attributes(
  #       stripe_id:       charge.id,
  #       card_last4:      charge.card.last4,
  #       card_expiration: Date.new(charge.card.exp_year, charge.card.exp_month, 1),
  #       card_type:       charge.card.type,
  #       fee_amount:      fee
  #     )
  #     self.finish!
  #   rescue Stripe::StripeError => e
  #     self.update_attributes(error: e.message)
  #     self.fail!
  #   end
  # end

  def self.create_for_cart(options={}) #needs to be changed
    transaction = new do |t|
      t.actioner = options[:actioner]
      t.actionee = options[:actionee]
      t.stripe_token = options[:stripe_token]
      t.amount = options[:amount]
    end
      # t.opt_in = options[:opt_in]
    #   t.affiliate_id = options[:affiliate].try(:id)

    #   if options[:coupon_id]
    #     t.coupon = Coupon.find(options[:coupon_id])
    #     t.amount = options[:product].price * (1 - t.coupon.percent_off / 100.0)
    #   else
    #     t.amount = options[:product].price
    #   end
    # end
    transaction
  end

  def self.create_for_show(options={})
  end

  def self.create_for_board(options={})
  end

  def queue_job!
    PaymentsWorker.perform_async(guid)
  end

  def populate_guid
    if new_record?
      while !valid? || self.guid.nil?
        self.guid = SecureRandom.random_number(1_000_000_000_000_000_000).to_s(32)
      end
    end
  end

  
end