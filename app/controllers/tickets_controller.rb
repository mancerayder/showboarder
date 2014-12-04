class TicketsController < ApplicationController
  def reserve
    @show = Show.find_by(id:params[:show_id])
    @quantity = params[:quantity].to_i
    if @quantity > 10
      redirect_to :back
    else
      @show.tickets_clear_expired_reservations

      if user_signed_in?
        @show.tickets_reserve(@quantity, current_user.id, current_user.class.to_s)
        redirect_to board_show_checkout_path(@show.board, @show)
      else
        @reserve_code = @show.tickets_reserve(@quantity, nil, nil)
        redirect_to board_show_checkout_path(@show.board, @show, reserve_code:@reserve_code)
      end
    end
  end

  def release
    @ticket = Ticket.find_by(guid: params[:ticket])

    if params[:reserve_code] # case for guest checkout.  Make new cart without released ticket + make ticket open, then send new cart reserve code
      @cart = Cart.find_by(reserve_code: params[:reserve_code])
      @cart.tickets.delete(@ticket)
      @ticket.carts.delete(@cart)
    end

    if @ticket.make_open 
      render :json => {ticket: @ticket.guid}, head: :ok
    else
      respond_to do |format|
        render :json => @ticket.errors, :status => :unprocessable_entity
      end
    end
  end
end