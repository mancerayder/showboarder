class Cart < ActiveRecord::Base
  has_and_belongs_to_many :tickets
  has_many :sales, as: :actionee
  has_many :charges, as: :actionee

  before_save :populate_reserve_code

  # def tickets_clear_expired_reservations
  #   self.tickets.each do |t|
  #     if t.expired?
  #       t.make_open("Reservation expired before state change")
  #     end
  #   end
  # end

  def amount
    amount = 0
    tickets.each do |t|
      amount = amount + (ticket.price*100).to_i
    end
    amount
  end

  def populate_reserve_code
    if new_record?
      while !valid? || (self.reserve_code == "")

        self.reserve_code = SecureRandom.hex(8).to_s
      end
    end
  end
end