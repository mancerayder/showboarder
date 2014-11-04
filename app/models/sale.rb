class Sale < ActiveRecord::Base
  # has_paper_trail

  belongs_to :actioner, polymorphic: true
  belongs_to :actionee, polymorphic: true
  has_many :charges
  has_one :subscription

  validates_uniqueness_of :guid

  before_save :populate_guid  

  def to_param
    guid
  end

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

  def charge_card
    begin
      ################## THE PART THAT SETS THE CUSTOMER AND CARD ###################
      if self.actioner_type == "User" #Customer and card for user

        if actioner.stripe_id #If user has an associated stripe customer, retrieve it
          customer = Stripe::Customer.retrieve(actioner.stripe_id)

          if token_type == "card" #If purchase is being made with saved card 
            card = customer.cards.retrieve(stripe_token)
          
          else #Else use the token to create the stripe card
            card = customer.cards.create(card:stripe_token)
          end

        else #If user does not have an associated stripe customer, create one for it and save it to the user
          customer = Stripe::Customer.create(
            email: self.actioner.email,
            description: "Actionee type: " + self.actionee_type + " Transaction ID: " + self.guid
            )

          card = customer.cards.create(card: stripe_token)

          actioner.update(stripe_id: customer.id)
        end

        if stripe_remember_card
          actioner.update(stripe_default_card: card.id)

          if actionee_type == "Board" || token_type == "card"
            customer.default_card = card.id
            customer.save
          end

          if token_type == "token"
            Card.create(user_id: actioner.id,
              stripe_id: card.id,
              last4: card.last4,
              expiration: Date.new(card.exp_year, card.exp_month, 1),
              brand: card.type,
              state: "confirmed"
              )
          end
        end

      else # Customer and card for guest
        customer = Stripe::Customer.create(
          email: actioner.email,
          description: "Guest - Actionee type: " + self.actionee_type + " Transaction ID: " + self.guid
          )

        card = customer.cards.create(card: stripe_token)
      end

      ################## THE PART THAT CREATES THE TOKEN/S AND CHARGE OR SUBSCRIPTION ###################
      if actionee_type == "Cart" #Creates charges for tickets
        owners = Hash.new { |hash, key| hash[key] =  []} # hash so tickets in cart can be grouped by board owner for efficient stripe charge creation

        actionee.tickets.each do |t| # separate tickets by board owners
          owners[t.show.board.owner.stripe_access_key] = owners[t.show.board.owner.stripe_access_key] << t.guid
        end

        owners.each do |o| # go through owners and make a charge for each one
          tickets_by_owner = Cart.create #array to temporarily store tickets for each owner to avoid having to look them up in the database by GUID again
          amount = 0
          #these build pieces of the description string with each ticket
          desc_b = "" #board string
          desc_s = "" #show string
          desc_t = "" #ticket string

          owners[o[0]].each do |t| #go through the tickets for the owner to make the charge
            ticket = Ticket.find_by(guid:t)
            tickets_by_owner.tickets << ticket
            desc_b = desc_b + ticket.show.board.name.to_s + " "
            desc_s = desc_s + ticket.show.id.to_s + " "
            desc_t = desc_t + t.to_s + " "
            amount = amount + (ticket.price*100).to_i
          end

          connect_token = Stripe::Token.create({ #make stripe token for each owner
              customer: customer.id,
              card: card.id
            }, o[0]
          )

          if charge = Stripe::Charge.create( # make charge with each stripe token
            {
              card: connect_token.id,
              amount: amount,
              currency: "usd",
              description: "Ticket purchase. BOARDS: " + desc_b + "SHOWS: " + desc_s + "TICKETS: " + desc_t + "TRANSACTION: " + self.guid.to_s
            },
            o[0]
          )
            tickets_by_owner.tickets.each do |t|
              t.buy(actioner)
            end

            Charge.create(sale:self, stripe_id:charge.id, amount:amount, actionee:tickets_by_owner, actioner:actioner) # create charge object that belongs to this sale
          end
        end

      else #Creates subscription for boards
        if sub = customer.subscriptions.create(
            plan: plan
            )

          actioner.board_role_assign(actionee, "owner")
          actionee.update(paid_tier:1, paid_at:Time.now)
          Subscription.create(user_id:actioner.id, board_id:actionee.id, paid_at: DateTime.now, paid_until: DateTime.now + 1.month, plan: plan, stripe_id: sub.id)
        end
      end # TODO : handle new default cards so they don't destroy the old ones - like for subscriptions. NOTE: not necessary unless stripe checkout is ditched
    self.finish!

    rescue Stripe::StripeError => e
      self.update_attributes(error: e.message)
      self.fail!
    end    
  end

  def amount
    return self.amount_base + self.amount_tip + self.amount_sb + self.amount_charity
  end

  def self.create_for_cart(options={})
    sale = new do |s|
      s.actioner = options[:actioner]
      s.actionee = options[:actionee]
      s.stripe_token = options[:stripe_token]
      s.stripe_remember_card = options[:stripe_remember_card]
      s.amount_base = options[:amount_base]
      s.amount_tip = options[:amount_tip]
      s.amount_sb = options[:amount_sb]
      s.amount_charity = options[:amount_charity]
      # total = 0

      # t.actionee.tickets.each do |e|
      #   total = total + (e.price * 100).to_i
      # end

      # t.amount = total
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
    # actioner.save
    sale
  end

  def self.create_for_board(options={})
    sale = new do |s|
      s.actioner = options[:actioner]
      s.actionee = options[:actionee]
      s.stripe_token = options[:stripe_token]
      s.plan = options[:plan]
      s.stripe_remember_card = options[:stripe_remember_card]
    end

    sale
  end

  def self.create_for_show(options={})
  end

  def queue_job!
    PaymentsWorker.perform_async(guid)
  end

  def token_type
    type = ""
    beginning = stripe_token[0..2]
    if beginning == "car"
      type = "card"
    elsif beginning == "tok"
      type = "token"
    end
    return type
  end

  def send_receipt
    # ReceiptMailer.delay.receipt(self.id)
    # MailchimpWorker.perform_async(guid) if Rails.configuration.mailchimp[:enabled]
  end

  def populate_guid
    if new_record?
      while !valid? || self.guid.nil?
        self.guid = SecureRandom.random_number(1_000_000_000_000_000_000).to_s(32)
      end
    end
  end

  
end