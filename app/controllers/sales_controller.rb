class SalesController < ApplicationController
  def show
    @sale = Sale.find_by!(guid: params[:guid])
  end

  def status
    @sale = Sale.where(guid: params[:guid]).first
    render nothing: true, status: 404 and return unless @sale
    render json: {guid: @sale.guid, status: @sale.state, error: @sale.error}
  end  

  def checkout
    @show = Show.find(params[:show_id])
    puts params[:stripeToken]
    token = params[:stripeToken]
    @board = Board.find_by_vanity_url(params[:board_id])
    @buyer = nil
    remember = false
    @actionee_type = "Cart"

    @amount = 0

    if user_signed_in? #find the reserved tickets, make a cart
      @buyer = current_user

      @cart = Cart.create(tickets: Ticket.where(ticket_owner_id:current_user.id, ticket_owner_type:current_user.class.to_s, state:"reserved"))

    else # if user not signed in, find the cart

      @email = params[:email].downcase

      if User.find_by_email(@email)
        render json: { error: "A user has already registered with that email address. Please log in." }, status: 400 and return
      end

      @buyer = Guest.find_or_create_by(email:@email) 

      if params[:reserve_code]
        @reserve_code = params[:reserve_code]

        @cart = Cart.find_by_reserve_code(@reserve_code)
      end
    end

    if @cart.tickets.count == 0 || @cart.has_expired?
      flash[:error] = "The transaction was cancelled because the reservation of one or more of the tickets in your cart had expired."
      flash.keep(:error)
      render :js => "window.location = '#{board_show_path(@board, @show)}'" and return
    else
      @sale = Sale.create_for_cart(
        actioner: @buyer,
        actionee: @cart,
        stripe_token: token,
        stripe_remember_card: remember,
        am_base: params[:am_base],
        am_added: params[:am_added],
        am_tip: params[:am_tip],
        am_sb: params[:am_sb],
        am_charity: params[:am_charity]
        )

      if @sale.save
        @buyer.update(name: params[:name])
        @sale.queue_job!
        render json: { guid: @sale.guid }
      else
        render json: { error: @sale.errors.full_messages.join(". ") }, status: 400
      end
    end
  end
end
