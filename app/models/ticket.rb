class Ticket < ActiveRecord::Base
  belongs_to :user
  belongs_to :ticket_owner, polymorphic: true
  belongs_to :show, dependent: :destroy
  belongs_to :referral_band

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
      if self.state == "reserved"
        transact(ticket_owner, "reserved", "open", "Your reservation for this ticket has expired.")
        self.update_attributes(ticket_owner_id: nil, ticket_owner_type: nil, state:"open", reserve_code: "")
      end
    end
  end

  def transact(actioner, state_before, state_after)
    Transaction.create(actioner_id:actioner.id, actioner_type:actioner.class.to_s, actionee_id:self.id, actionee_type:"Show", state_before:state_before, state_after:state_after)
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

  def state_change(state, ticket_owner_id, ticket_owner_type)
    self.update_attributes(state:state,ticket_owner_id:ticket_owner_id, ticket_owner_type: ticket_owner_type)
    if state == "reserved"
      self.update_attributes(state:state,reserved_at:Time.now)
      self.buy_or_die
    end
    if state == "bought"
      if (self.state == "reserved") || (self.ticket_owner_id != ticket_owner_id)
        self.update_attributes(state:state,bought_at:Time.now)
      else
        flash[:error] = "Sorry, your reservation timer for this ticket has expired or you are not the reserver.  Please purchase within 15 minutes of reserving."
        redirect_to show_path(self.show)
      end
    end
    if state == "open"
      self.update_attributes(state:state,canceled_at:Time.now)
    end
  end

  def owner(user_or_guest)
    self.update_attributes(ticket_owner_type:user_or_guest.class.to_s, ticket_owner_id:user_or_guest.id)
  end

  def make_open
    self.update_attributes(ticket_owner_type:nil, ticket_owner_id:nil, state:"open")
  end
end