class Show < ActiveRecord::Base
  belongs_to :stage, dependent: :destroy
  belongs_to :board, dependent: :destroy
  has_many :tickets

  def make_tickets
    if self.custom_capacity
      capacity = self.custom_capacity.to_i
    else
      capacity = self.board.stages.first.capacity.to_i
    end
    puts "flable"
    puts self.stage.capacity.to_i
    (1..capacity).each do |t|
      puts "ticketarino" + t.to_s
      self.tickets.create
    end
  end

end
