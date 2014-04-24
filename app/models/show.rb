class Show < ActiveRecord::Base
  belongs_to :stage, dependent: :destroy
  belongs_to :board, dependent: :destroy
  has_many :tickets

  def tickets_make
    if self.custom_capacity
      capacity = self.custom_capacity.to_i
    else
      capacity = self.board.stages.first.capacity.to_i
    end

    puts self.stage.capacity.to_i
    (1..capacity).each do |t|
      self.tickets.create(price:self.price_adv)
    end
  end

  def unsold_count
    unsold = 0
    self.tickets.each do |t|
      if t.state == "owned"
        unsold_count = unsold_count + 1
      end
    end
    return unsold
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

  def tickets_state(state, quantity, buyer_id, buyer_type)
    if self.unsold_count <= quantity
      (1..quantity)
      #go through tickets of state that should be changed by state and change state buyer_id and buyer_type as appropriate via ticket state method 
    else
      flash[:error] = "Sorry, not enough tickets are available at this time."
      redirect to show_path(@show)
    end
  end
end
