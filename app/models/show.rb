class Show < ActiveRecord::Base
  belongs_to :stage, dependent: :destroy
  belongs_to :board, dependent: :destroy
  has_many :ext_links, as: :linkable
  has_many :tickets
  has_many :sales, as: :actionee
  validates :ticketing_type, presence: true
  has_and_belongs_to_many :acts
  accepts_nested_attributes_for :acts, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :ext_links, :reject_if => :all_blank, :allow_destroy => true

  def transact(actioner, state_before, state_after)
    Sale.create(actioner_id:actioner.id, actioner_type:actioner.class.to_s, actionee_id:self.id, actionee_type:"Show", state_before:state_before, state_after:state_after)
  end

  def tickets_make  # needs to account for paid, pwyw, rsvp_only
    if self.custom_capacity?
      capacity = self.custom_capacity.to_i
    else
      capacity = self.board.stages.first.capacity.to_i
    end

    (1..capacity).each do |t|
      self.tickets.create(price:self.price_adv)
    end
  end

  def unsold_count
    return self.tickets.where(state:"open").count
  end

  def tickets_adjust(quantity)
    if self.tickets.count < quantity
      (self.tickets.count..quantity-1).each do |t|
        self.tickets.create
      end
    else
      if self.unsold_count > self.tickets.count - quantity
        self.tickets.each do |t|
          if t.bought_at == nil
            t.destroy
          end
          break if self.tickets.count == quantity
        end
      else
        flash[:error] = "Sorry, you cannot adjust capacity below the amount of tickets that have already sold."
        redirect_to show_path(@show)
      end
    end
  end

  def tickets_reserve(quantity, reserver_id = nil, reserver_type = nil)
    if self.unsold_count >= quantity
      # reserve_code = ""
      #go through tickets of state that should be changed by state and change state buyer_id and buyer_type as appropriate via ticket state method 
      open = Ticket.where(show_id:self.id, state:"open")

      cart = Cart.create(tickets:open[0..(quantity-1)])

      cart.tickets.each do |t|
        t.update_attributes(state:"reserved", ticket_owner_id:reserver_id, ticket_owner_type:reserver_type, reserved_at:DateTime.now)
        t.buy_or_die
      end

      if reserver_id == nil
        return cart.reserve_code
      end
    else
      raise "Sorry, not enough tickets are available at this time." # todo - say it's sold out instead of giving error page
    end
  end

  def tickets_buy(quantity, buyer_id, buyer_type)
    reserved = Ticket.where(show_id:self.id, state:"reserved", ticket_owner_id:buyer_id, ticket_owner_type:buyer_type)
    if reserved.length >= quantity
      (0..quantity-1).each do |t|
        reserved[t].update_attributes(state:"owned", bought_at:Time.now, buy_method:"online")
      end
    else
      raise "Sorry, not enough tickets are reserved by this user or guest."
      # redirect to show_path(@show)
    end
  end

  def tickets_clear_expired_reservations
    reserved = Ticket.where(show_id:self.id, state:"reserved")
    reserved.each do |t|
      if t.expired?
        t.make_open
      end
    end
  end

  # def tickets_state(state, quantity, buyer_id, buyer_type)
  #   if self.unsold_count <= quantity
  #     #go through tickets of state that should be changed by state and change state buyer_id and buyer_type as appropriate via ticket state method 
  #     self.tickets.each do |t|
  #       if state == "reserved"
  #         if t.state == "open"
  #           t.update_attributes(state:state,ticket_owner_id:buyer_id, ticket_owner_type:buyer_type)
  #           quantity = quantity - 1
  #         end
  #       end
  #       if state == "owned"
  #         if t.state == ("open" || "canceled")
  #           t.update_attributes(state:state,ticket_owner_id:buyer_id, ticket_owner_type:buyer_type)
  #           quantity = quantity - 1
  #         end
  #       end
  #       break if quantity == 1
  #     end
  #   else
  #     flash[:error] = "Sorry, not enough tickets are available at this time."
  #     redirect to show_path(@show)
  #   end
  # end
end
