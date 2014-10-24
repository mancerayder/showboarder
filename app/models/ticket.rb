class Ticket < ActiveRecord::Base
  belongs_to :user
  belongs_to :ticket_owner, polymorphic: true
  belongs_to :show, dependent: :destroy
  belongs_to :referral_band
  has_and_belongs_to_many :carts


  validates_uniqueness_of :guid

  before_save :populate_guid
  
  def to_param
    guid
  end

  def populate_guid
    if new_record?
      while !valid? || self.guid.nil?
        self.guid = SecureRandom.random_number(1_000_000_000_000_000_000).to_s(32)
      end
    end
  end  

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
    if (self.reserved_at && (DateTime.now - DateTime.parse(self.reserved_at.to_s)) > (DateTime.now - (DateTime.now - 15.minutes))) || (self.state != "reserved")
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

    Sale.create(actioner_id:actioner_id, actioner_type:actioner_type, actionee_id:self.id, actionee_type:"Ticket", state_before:state_before, state_after:state_after, error:error)
  end

  def buy(user_or_guest)
    if self.expired?
      self.make_open
      raise "The reservation for this ticket has expired"
    end
    self.reload
    self.update(state:"owned", ticket_owner_id:user_or_guest.id, ticket_owner_type:user_or_guest.class.to_s)
  end

  def use
    self.update(state:"used")
  end

  def unuse
    self.update(state:"owned")
  end  

  def owner(user_or_guest)
    self.update_attributes(ticket_owner_type:user_or_guest.class.to_s, ticket_owner_id:user_or_guest.id)
  end

  def make_open(error = "Make open")
    self.reload
    self.update_attributes(ticket_owner_type: nil, ticket_owner_id: nil, state:"open", reserved_at: nil)
  end
end