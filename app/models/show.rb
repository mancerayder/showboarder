class Show < ActiveRecord::Base
  belongs_to :stage
  belongs_to :board
  has_many :ext_links, as: :linkable, dependent: :destroy
  has_many :tickets, dependent: :destroy
  has_many :sales, as: :actionee, dependent: :destroy
  validates :ticketing_type, :price_door, :price_adv, presence: true
  has_and_belongs_to_many :acts
  accepts_nested_attributes_for :acts, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :ext_links, :reject_if => :all_blank, :allow_destroy => true
  delegate :vanity_url, :to => :board, :prefix => true
  before_save :normalize_category

  def destroy
    raise "Cannot delete a show with sold tickets. Email contact@showboarder.com if you need to do this" unless self.tickets_sold == 0
    # ... ok, go ahead and destroy
    super
  end

  def transact(actioner, state_before, state_after)
    Sale.create(actioner_id:actioner.id, actioner_type:actioner.class.to_s, actionee_id:self.id, actionee_type:"Show", state_before:state_before, state_after:state_after)
  end

  def acts_twitter_or_name
    combined = "" 
    self.acts.each do |act|
      combined += act.twitter_or_name
      if act != self.acts.last
        combined += ", "
      end
    end
    if combined.length > 2
      combined = "featuring " + combined
    end
    return combined
  end

  def normalize_category
    if self.category == "Business"
      self.category = "BusinessEvent"
      elsif self.category == "Comedy"
        self.category = "ComedyEvent"
      elsif self.category == "Dance"
        self.category = "DanceEvent"
      elsif self.category == "Food"
        self.category = "FoodEvent"
      elsif self.category == "Literary"
        self.category = "LiteraryEvent"
      elsif self.category == "Music"
        self.category = "MusicEvent"
      elsif self.category == "Sale"
        self.category = "SaleEvent"
      elsif self.category == "Social"
        self.category = "SocialEvent"
      elsif self.category == "Sports"
        self.category = "SportsEvent"
      elsif self.category == "Theater"
        self.category = "TheaterEvent"
    end
  end

  def denormalize_category
    if self.category == "BusinessEvent"
      return "Business"
      elsif self.category == "ComedyEvent"
        return "Comedy"
      elsif self.category == "DanceEvent"
        return "Dance"
      elsif self.category == "FoodEvent"
        return "Food"
      elsif self.category == "LiteraryEvent"
        return "Literary"
      elsif self.category == "MusicEvent"
        return "Music"
      elsif self.category == "SaleEvent"
        return "Sale"
      elsif self.category == "SocialEvent"
        return "Social"
      elsif self.category == "SportsEvent"
        return "Sports"
      elsif self.category == "TheaterEvent"
        return "Theater"
      else
        return category
    end
  end

  def tickets_make  # needs to account for paid, pwyw, rsvp_only
    if self.ticketing_type == "paid" || self.ticketing_type == "Ticketed"
      if self.custom_capacity?
        capacity = self.custom_capacity.to_i
      else
        capacity = self.board.stages.first.capacity.to_i
      end

      (1..capacity).each do |t|
        self.tickets.create(price:self.price_adv)
      end
    elsif self.ticketing_type == "rsvp"

    elsif self.ticketing_type == "pwyw"
    end #note that type of free just doesn't do anything
  end

  def unsold_count
    return self.tickets.where(state:"open").count
  end

  def tickets_price_update
    self.tickets.where(state:"open").each do |t|
      t.update(price:self.price_adv)
    end
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
        redirect_to board_show_path(@show.board, @show)
      end
    end
  end

  def tickets_reserve(quantity, reserver_id = nil, reserver_type = nil, reserve_code = nil)
    if self.unsold_count >= quantity
      #go through tickets of state that should be changed by state and change state buyer_id and buyer_type as appropriate via ticket state method 
      open = Ticket.where(show_id:self.id, state:"open")

      if reserve_code && quantity == 1 # TODO: catch if this is somehow ever hit with a quantity other than 1
        cart = Cart.find_by(reserve_code: reserve_code)
        added_ticket = open.first
        cart.tickets << added_ticket
        added_ticket.update_attributes(state:"reserved", ticket_owner_id:reserver_id, ticket_owner_type:reserver_type, reserved_at:DateTime.now)
      else

        cart = Cart.create(tickets:open[0..(quantity-1)])

        cart.tickets.each do |t|
          t.update_attributes(state:"reserved", ticket_owner_id:reserver_id, ticket_owner_type:reserver_type, reserved_at:DateTime.now)
          # t.buy_or_die
        end
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

  def acts_stringed
    stringed = ""
    self.acts.each do |a|
      stringed = stringed + a.name
      if a != self.acts.last
        stringed = stringed + " - "
      end
    end
    return stringed
  end

  def attendees
    attendees = Hash.new { |hash, key| hash[key] = []}

    self.tickets.where('state=? OR state=?', 'owned', 'used').each do |t|
      attendees[t.ticket_owner.name] = attendees[t.ticket_owner.name] << t
    end
    return attendees
  end
  
  def checkin_attendee(id, type)
    tickets = self.tickets.where(ticket_owner_id: id, ticket_owner_type: type, state: "owned")

    tickets.each do |t|
      t.use
    end
  end

  def tickets_sold
    total_sold = 0
    self.tickets.each do |t|
      if t.state != "open"
        total_sold += 1
      end
    end
    return total_sold
  end

  def checkout_attendee(id, type)
    tickets = self.tickets.where(ticket_owner_id: id, ticket_owner_type: type, state: "used")

    tickets.each do |t|
      t.unuse
    end
  end
end
