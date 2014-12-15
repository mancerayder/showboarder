class TicketsController < ApplicationController
  def reserve
    @show = Show.find_by(id:params[:show_id])
    @quantity = params[:quantity].to_i
    if @quantity > 10
      flash[:error] = "Sorry, you may not reserve more tickets than the maximum of 10."
      redirect_to :back
    else
      @show.tickets_clear_expired_reservations

      if user_signed_in?
        @show.tickets_reserve(@quantity, current_user.id, current_user.class.to_s, nil)
        redirect_to board_show_checkout_path(@show.board, @show)
      else
        if params[:reserve_code]
          @show.tickets_reserve(1, nil, nil, params[:reserve_code]) # TODO properly record guests instead of nil
          render :json => { head: :ok }
        else
          @reserve_code = @show.tickets_reserve(@quantity, nil, nil, nil)
          redirect_to board_show_checkout_path(@show.board, @show, reserve_code:@reserve_code)
        end
      end
    end
  end

  def clear
    if user_signed_in?
      current_user.tickets.where(state:"reserved").each do |t|
        t.make_open
      end
    else
      Cart.find_by(reserve_code: params[:reserve_code]).tickets.each do |t|
        t.make_open
      end
    end
    render :json => { head: :ok }
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