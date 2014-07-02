class TransactionsController < ApplicationController
  # def reserve
  #   @show = Show.find_by(params[:show_id])
  # end
  # def checkout
  #   reserve_code = params[:reserve_code]
  #   @show = find_by(params[:show_id])
  #   @tickets = []
  #   reserve_code.split("-").each do |c|
  #     @tickets << Ticket.where(show_id:@show.id, reserve_code:c).first
  #   end
  # end

  def show
    @transaction = Transaction.find_by!(guid: params[:guid])
    # @product = @sale.product
  end

  def status
    @transaction = Transaction.where(guid: params[:guid]).first
    render nothing: true, status: 404 and return unless @transaction
    render json: {guid: @transaction.guid, status: @transaction.state, error: @transaction.error}
  end  

  def checkout
    @show = Show.find(params[:show_id])
    token = params[:stripeToken]
    @board = Board.find_by_vanity_url(params[:board_id])
    @buyer = nil
    @tickets = []

    @amount = 0

    if user_signed_in? #find the reserved tickets, clear the expired ones, make a cart

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

    else #find the cart, clear the expired ones, re-save the cart

      @email = params[:email].downcase

      if User.find_by_email(@email)
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

    @transaction = Transaction.create_for_cart(
      actioner: @buyer,
      actionee: @cart,
      stripe_token: token,
      )

    if @transaction.save
      @transaction.queue_job!
      render json: { guid: @transaction.guid }
    else
      render json: { error: @sale.errors.full_messages.join(". ") }, status: 400
    end    
  end

  def board_ticketed #new version for transactions
    @board = Board.find_by_vanity_url(params[:board_id])
    token = params[:stripeToken]

    @transaction = Transaction.create_for_board(
      actioner: current_user,
      actionee: @board,
      plan: "sb1",
      stripe_token: token
      )

    if @transaction.save
      @transaction.queue_job!
      render json: { guid: @transaction.guid }
    else
      render json: { error: @sale.errors.full_messages.join(". ") }, status: 400
    end
  end

  # def board_ticketed #old version
  #   begin
  #   token = params[:stripeToken]

  #   @amount = "2500"

  #   @board = Board.find_by_vanity_url(params[:board_id])

  #   if current_user.stripe_id
  #     customer = Stripe::Customer.retrieve(current_user.stripe_id)
  #     subscription = customer.subscriptions.create(
  #       :plan => "sb1"
  #       )
  #   else
  #     customer = Stripe::Customer.create(
  #       :card => token,
  #       :plan => "sb1",
  #       :email => current_user.email
  #     )

  #     current_user.update_attributes(stripe_id:customer.id)
  #   end

  #   @board.user_boards.find_by(boarder_id:current_user.id).update_attributes(role:"owner")
  #   @board.update_attributes(paid_at:Time.now)

  #   redirect_to @board, :notice => "You have successfully enabled ticketing for this board!"
  #   rescue Stripe::CardError => e
  #     flash[:error] = e.message
  #     redirect_to board_charges_path(@board)
  #   end
  # end

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
