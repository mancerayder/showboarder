class Ticket < ActiveRecord::Base
  belongs_to :user
  belongs_to :ticket_owner, polymorphic: true
  belongs_to :show, dependent: :destroy
  belongs_to :referral_band

  include AASM

  aasm column: 'state', skip_validation_on_save: true do
    state :open, initial: true
    state :reserved
    state :owned

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

  def buy_or_die
    Rufus::Scheduler.singleton.in '15m' do
      if self.state == "reserved"
        self.update_attributes(ticket_owner_id: nil, ticket_owner_type: nil, state:"open")
      end
    end
  end

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