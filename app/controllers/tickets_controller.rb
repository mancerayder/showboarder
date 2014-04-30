class TicketsController < ApplicationController
  # def new
  #   @board = Board.find_by_vanity_url(params[:board_id])
  #   @show = Show.find(params[:show_id])
  #   @quantity = params[:quantity]
  #   # @amount = @show.price_adv * BigDecimal.new(@quantity)
  #   @amount = ((@show.price_adv * BigDecimal.new(@quantity)) * 100).to_i
  # end

  # def reserve
  #   @show = Show.find(params[:show_id])
  #   @quantity = params[:quantity]

  #   if user_signed_in?
  #     redirect_to current_user
  #   else
  #     redirect_to current_user
  #   end
  # end
  def create
    if params[:charge_type] == "sb3"
      begin
      @show = Show.find(params[:show_id])
      token = params[:stripeToken]
      @quantity = params[:quantity].to_i
      @amount = ((@show.price_adv * BigDecimal.new(@quantity)) * 100).to_i
      @board = Board.find_by_vanity_url(params[:board_id])
      buyer_id = 0
      buyer_type = ""

      if user_signed_in?
        buyer_id = current_user.id
        buyer_type = "User"
      else
        @email = params[:email].downcase

        if User.find_by_email(@email)
          flash[:error] = "A user has already registered with that email address. Please log in."
          redirect_to :back
        end

        @guest = Guest.find_or_create_by(email:@email)
        buyer_id = @guest.id
        buyer_type = "Guest"
      end

      if @show.unsold_count >= @quantity
        @show.tickets_reserve(@quantity, buyer_id, buyer_type)
      else
        flash[:error] = "Sorry, not enough tickets are available at this time."
        redirect_to @show
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
            :email => @guest.email,
            :description => "Single show ticketing - new"
            )
          charge = Stripe::Charge.create(
            :customer => customer.id,
            :amount => @amount,
            :currency => "usd",
            :description => @show.id.to_s + " " + @quantity.to_s + " " + @guest.id.to_s
            )
      end

      @show.tickets_buy(@quantity, buyer_id, buyer_type)
      

      redirect_to @show.board, :notice => "Enjoy the show!"
      rescue Stripe::CardError => e
        flash[:error] = e.message
        redirect_to root_path
      end
    end
  end
end