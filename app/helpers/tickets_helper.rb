module TicketsHelper

  def sold_out(show, needed)
    show.tickets.where(state:"open").length < needed
  end

end
