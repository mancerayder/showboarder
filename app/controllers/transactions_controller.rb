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

  def checkout
    if params[:charge_type] == "sb3"
      begin
      @show = Show.find(params[:show_id])
      token = params[:stripeToken]
      @board = Board.find_by_vanity_url(params[:board_id])
      @buyer = nil

      @amount = 0

      if user_signed_in?
        @tickets = Ticket.where(ticket_owner_id:current_user.id, ticket_owner_type:current_user.class.to_s, state:"reserved")
        @buyer = current_user
      else
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
          @reserve_code.split("-").each do |c|
            t = Ticket.where(show_id:c.split("_")[1].to_i, reserve_code:c).first
            if t && !t.expired?
              @tickets << t
            elsif t
              t.make_open("Reservation expired before state change")
            else
              next
            end
          end
        end
      end

      @tickets.each do |t|
        @amount = @amount + (t.price * 100).to_i
      end

      if user_signed_in?
        if current_user.stripe_id
          customer = Stripe::Customer.retrieve(current_user.stripe_id)
          charge = Stripe::Charge.create(
            :customer => customer.id,
            :amount => @amount,
            :currency => "usd",
            :description => @show.id.to_s + " " + @quantity.to_s
            )
        else
          customer = Stripe::Customer.create(
            :card => token,
            :email => current_user.email,
            :description => "Single show ticketing - new"
            )
          charge = Stripe::Charge.create(
            :customer => customer.id,
            :amount => @amount,
            :currency => "usd",
            :description => @show.id.to_s + " " + @quantity.to_s
            )

          current_user.update_attributes(stripe_id:customer.id)
        end
      else

        customer = Stripe::Customer.create(
            :card => token,
            :email => @buyer.email,
            :description => "Single show ticketing - new"
            )
          charge = Stripe::Charge.create(
            :customer => customer.id,
            :amount => @amount,
            :currency => "usd",
            :description => @show.id.to_s + " " + @quantity.to_s + " " + @buyer.id.to_s + " " + @buyer.class.to_s
            )
      end

      @tickets.each do |t|
        t.buy(@buyer)
      end

      redirect_to @show.board, :notice => "Enjoy the show!"
      rescue Stripe::CardError => e
        flash[:error] = e.message

        redirect_to root_path
      end
    end
  end

  def board_ticketed
    if params[:charge_type] == "sb1"
      begin
      token = params[:stripeToken]

      @amount = "2500"

      @board = Board.find_by_vanity_url(params[:board_id])

      if current_user.stripe_id
        customer = Stripe::Customer.retrieve(current_user.stripe_id)
        subscription = customer.subscriptions.create(
          :plan => "sb1"
          )
      else
        customer = Stripe::Customer.create(
          :card => token,
          :plan => "sb1",
          :email => current_user.email
        )

        current_user.update_attributes(stripe_id:customer.id)
      end

      @board.user_boards.find_by(boarder_id:current_user.id).update_attributes(role:"owner")
      @board.update_attributes(paid_at:Time.now)


      redirect_to @board, :notice => "You have successfully enabled ticketing for this board!"
      rescue Stripe::CardError => e
        flash[:error] = e.message
        redirect_to board_charges_path(@board)
      end
    end
  end

  def show_ticketed
    if params[:charge_type] == "sb2"
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
      @show.transact(current_user, "open", "paid")
      @show.tickets_make


      redirect_to @show.board, :notice => "You have successfully enabled ticketing for this show!"
      rescue Stripe::CardError => e
        flash[:error] = e.message
        redirect_to board_charges_path(@board)
      end
    end
  end  
end
