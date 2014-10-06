class SalesController < ApplicationController
  def show
    @sale = Sale.find_by!(guid: params[:guid])
    # @product = @sale.product
  end

  def status
    @sale = Sale.where(guid: params[:guid]).first
    render nothing: true, status: 404 and return unless @sale
    render json: {guid: @sale.guid, status: @sale.state, error: @sale.error}
  end  

  def checkout
    @show = Show.find(params[:show_id])
    token = params[:stripeToken]
    @board = Board.find_by_vanity_url(params[:board_id])
    @buyer = nil
    @tickets = []
    remember = false
    @actionee_type = "Cart"

    @amount = 0

    if user_signed_in? #find the reserved tickets, clear the expired ones, make a cart
      # TODO replace the existing reserved tickets stuff with the commented out
      # but only once it's confirmed that everything else is working
      # @buyer = current_user
      # @tickets = current_user.tickets_retrieve_and_clear_expired
      reserved_tickets = Ticket.where(ticket_owner_id:current_user.id, ticket_owner_type:current_user.class.to_s, state:"reserved")
      @buyer = current_user
      reserved_tickets.each do |t|
        if t && !t.expired?
            @tickets << t
        elsif t
          t.make_open("Reservation expired before state change")
        else
          next
        end
      end
      @cart = Cart.create(tickets:@tickets)
      remember = params[:stripe_remember_card]
      puts remember
      if remember == "true"
        remember = true
      else
        remember = false
      end

    else #find the cart, clear the expired ones, re-save the cart

      @email = params[:email].downcase

      if User.find_by_stripe_email(@email)
        flash[:error] = "A user has already registered with that email address. Please log in."
        redirect_to :back
      end

      @buyer = Guest.find_or_create_by(email:@email)
      @reserve_code = ""
      @tickets = []
      if params[:reserve_code]
        @reserve_code = params[:reserve_code]

        @cart = Cart.find_by_reserve_code(@reserve_code)

        @cart.tickets.each do |t|
          if t && !t.expired?
            @tickets << t
          elsif t
            t.make_open("Reservation expired before state change")
          else
            next
          end
        end

        @cart.tickets = @tickets
      end
    end

    @sale = Sale.create_for_cart(
      actioner: @buyer,
      actionee: @cart,
      stripe_token: token,
      stripe_remember_card: remember
      )

    if @sale.save
      @sale.queue_job!
      render json: { guid: @sale.guid }
    else
      render json: { error: @sale.errors.full_messages.join(". ") }, status: 400
    end    
  end

  def board_ticketed #new version for sales
    @board = Board.find_by_vanity_url(params[:board_id])
    token = params[:stripeToken]
    remember = params[:stripe_remember_card]

    @sale = Sale.create_for_board(
      actioner: current_user,
      actionee: @board,
      plan: "sb1",
      stripe_token: token,
      stripe_remember_card: remember
      )

    if @sale.save
      @sale.queue_job!
      render json: { guid: @sale.guid }
    else
      render json: { error: @sale.errors.full_messages.join(". ") }, status: 400
    end
  end

  def show_ticketed
    begin
    token = params[:stripeToken]

    @amount = "1000"

    @board = Board.find_by_vanity_url(params[:board_id])
    @show = Show.find_by(params[:id])

    if current_user.stripe_id
      customer = Stripe::Customer.retrieve(current_user.stripe_id)
      charge = Stripe::Charge.create(
        :customer => customer.id,
        :amount => @amount,
        :currency => "usd",
        :description => @show.id
        )
    else
      customer = Stripe::Customer.create(
        :card => token,
        :amount => @amount,
        :email => current_user.email,
        :description => "Single show ticketing - new"
      )

      current_user.update_attributes(stripe_id:customer.id)
    end

    @show.update_attributes(payer_id:current_user.id, paid_at:Time.now)
    @show.tickets_make


    redirect_to @show.board, :notice => "You have successfully enabled ticketing for this show!"
    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to board_charges_path(@board)
    end
  end
end
