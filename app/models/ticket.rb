class Ticket < ActiveRecord::Base
  # has_paper_trail

  belongs_to :user
  belongs_to :ticket_owner, polymorphic: true
  belongs_to :show, dependent: :destroy
  belongs_to :referral_band
  has_and_belongs_to_many :carts

  # include AASM

  # aasm column: 'state', skip_validation_on_save: true do
  #   state :open, initial: true
  #   state :reserved
  #   state :owned

  #   event :process, after: :charge_card do
  #     transitions from: :open, to: :reserved
  #     transact(ticket_owner, "open", "reserved", '')
  #   end

  #   event :finish, after: :send_receipt do
  #     transitions from: :reserved, to: :owned
  #     transact(ticket_owner, "reserved", "owned", '')
  #   end

  #   event :fail do
  #     transitions from: :processing, to: :open
  #   end

  #   event :refund, after: :send_refund_email do
  #     transitions from: :finished, to: :open
  #   end
  # end

  def buy_or_die
    Rufus::Scheduler.singleton.in '15m' do
      self.reload
      if self.state == "reserved"
        self.reload
        self.make_open("Scheduled reservation expiration")
      end
    end
  end

  def expired?
    if ((DateTime.now - DateTime.parse(self.reserved_at.to_s)) > (DateTime.now - (DateTime.now - 15.minutes))) || (self.state != "reserved")
      true
    else
      false
    end
  end

  def transact(actioner, state_before, state_after, error = "")
    if actioner != nil
      actioner_id = actioner.id
      actioner_type = actioner.class.to_s
    else
      actioner_id = nil
      actioner_type = nil
    end

    Transaction.create(actioner_id:actioner_id, actioner_type:actioner_type, actionee_id:self.id, actionee_type:"Ticket", state_before:state_before, state_after:state_after, error:error)
  end

  # def transaction_last(owner)
  #   Transaction.where(actioner_type:owner.class.to_s, actioner_id:owner.id, actionee_type:"Ticket", actionee_id:self.id).order(:created_at).last
  # end

  # def transaction_last
  #   Transaction.where(actionee_type:"Ticket", actionee_id:self.id).order(:created_at).last
  # end

  # def transactions(owner)
  #   Transaction.where(actioner_type:owner.class.to_s, actioner_id:owner.id, actionee_type:"Ticket", actionee_id:self.id)
  # end

  # def transactions_all
  #   Transaction.where(actionee_type:"Ticket", actionee_id:self.id)
  # end

  # def state_change(state, ticket_owner_id, ticket_owner_type)
  #   self.update_attributes(state:state,ticket_owner_id:ticket_owner_id, ticket_owner_type: ticket_owner_type)
  #   if state == "reserved"
  #     self.update_attributes(state:state,reserved_at:DateTime.now)
  #     self.buy_or_die
  #   end
  #   if state == "owned"
  #     if (self.state == "reserved") || (self.ticket_owner_id != ticket_owner_id)
  #       self.update_attributes(state:state,bought_at:DateTime.now)
  #     else
  #       flash[:error] = "Sorry, your reservation timer for this ticket has expired or you are not the reserver.  Please purchase within 15 minutes of reserving."
  #       redirect_to show_path(self.show)
  #     end
  #   end
  #   if state == "open"
  #     self.update_attributes(state:state,canceled_at:DateTime.now)
  #   end
  # end

  def buy(user_or_guest)
    if self.expired?
      self.make_open
      raise "The reservation for this ticket has expired"
    end
    # self.transact(user_or_guest, self.state, "owned")
    self.reload
    self.update(state:"owned", ticket_owner_id:user_or_guest.id, ticket_owner_type:user_or_guest.class.to_s)
  end

  def owner(user_or_guest)
    self.update_attributes(ticket_owner_type:user_or_guest.class.to_s, ticket_owner_id:user_or_guest.id)
  end

  def make_open(error = "Make open")
    # self.transact(self.ticket_owner, self.state.to_s, "open", error)
    self.reload
    self.update_attributes(ticket_owner_type: nil, ticket_owner_id: nil, state:"open", reserved_at: nil)
  end
end