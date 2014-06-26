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
    begin
      #######################################################################
      ########################## FOR TICKET PURCHASE ########################
      #######################################################################
      if self.actionee_type == "Cart"
        if actioner.class.to_s == "User"

          if actioner.stripe_id?
            customer = Stripe::Customer.retrieve(actioner.stripe_id)
            
            #this checked if the card was already saved to the user but it returns a 404 instead of false if it is not
            #not sure if that breaks it
            # if !c.cards.retrieve(self.stripe_token)
            #   c.cards.create(card:self.stripe_token)
            # end

            customer.card = self.stripe_token
            customer.save

          else

            customer = Stripe::Customer.create(
              card: self.stripe_token,
              email: actioner.stripe_email,
              description: actionee.tickets.count.to_s + " ticket purchase" #maybe add more detail here
            )
            
            actioner.update(stripe_id:customer.id)

          end
        else
          customer = Stripe::Customer.create(
              card: self.stripe_token,
              email: actioner.stripe_email,
              description: actionee.tickets.count.to_s + " ticket purchase" #maybe add more detail here
            )
        end

        actionee.tickets.each do |t|
          access_key = t.show.board.owner.stripe_access_key

          connect_token = Stripe::Token.create({
              customer:customer.id
            }, access_key
          )

        
          if charge = Stripe::Charge.create(
            {
              card: connect_token.id,
              amount: (t.price*100).to_i,
              currency: "usd",
              description: "Ticket purchase" #maybe add more detail here
            },
            access_key
          )

            t.buy(actioner) 
          end
        end

        self.update_attributes(
          stripe_id:       charge.id
        )

        if actioner.class.to_s == "User"
          self.actioner.update_attributes(
            stripe_id:customer.id,
            card_last4:      charge.card.last4,
            stripe_email:customer.email.downcase,
            card_expiration: Date.new(charge.card.exp_year, charge.card.exp_month, 1),
            card_type:       charge.card.type,      
            )
        end

      #######################################################################
      ######################## FOR BOARD SUBSCRIPTION #######################
      #######################################################################
      elsif actionee_type == "Board"
        if actioner.stripe_id
          customer = Stripe::Customer.retrieve(actioner.stripe_id)
          subscription = customer.subscriptions.create(
            plan: plan
            )
        else
          customer = Stripe::Customer.create(
            :card => stripe_token,
            :plan => plan,
            :email => actioner.stripe_email
          )

          actioner.update_attributes(stripe_id:customer.id)
          self.update_attributes(stripe_subscription_id:customer.subscriptions.first.id)
        end

        actioner.board_role_assign(actionee, "owner")
        # actionee.user_boards.find_by(boarder_id:actioner.id).update_attributes(role:"owner")
        actionee.update_attributes(paid_at:Time.now)

        
      #######################################################################
      ######################### FOR SHOW PURCHASE ###########################
      #######################################################################
      elsif actionee_type == "Show"
        # if actioner.stripe_id

      end
      self.finish!
    rescue Stripe::StripeError => e
      self.update_attributes(error: e.message)
      self.fail!
    end
  end

  def self.create_for_cart(options={}) #needs to be changed
    transaction = new do |t|
      t.actioner = options[:actioner]
      t.actionee = options[:actionee]
      t.stripe_token = options[:stripe_token]
      total = 0

      t.actionee.tickets.each do |e|
        total = total + (e.price * 100).to_i
      end

      t.amount = total
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

  def self.create_for_board(options={})
    transaction = new do |t|
      t.actioner = options[:actioner]
      t.actionee = options[:actionee]
      t.stripe_token = options[:stripe_token]
      t.plan = options[:plan]
      t.amount = 2500
    end

    transaction
  end

  def self.create_for_show(options={})
  end


  def queue_job!
    PaymentsWorker.perform_async(guid)
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