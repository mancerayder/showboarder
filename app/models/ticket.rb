class Ticket < ActiveRecord::Base
  belongs_to :user
  belongs_to :ticket_owner, polymorphic: true
  belongs_to :show, dependent: :destroy
  belongs_to :referral_band

  def buy_or_die
    scheduler.in '15m' do
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
end