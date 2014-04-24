class TicketsController < ApplicationController
  def new
    @board = Board.find_by_vanity_url(params[:board_id])
    @show = Show.find(params[:show_id])
    @quantity = params[:quantity]
    # @amount = @show.price_adv * BigDecimal.new(@quantity)
    @amount = ((@show.price_adv * BigDecimal.new(@quantity)) * 100).to_i
  end

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
      @quantity = params[:quantity]
      # puts "froop" + @quantity.to_s
      # puts "frop" + @show.price_adv.to_s
      @amount = ((@show.price_adv * BigDecimal.new(@quantity)) * 100).to_i
      @board = Board.find_by_vanity_url(params[:board_id])
      buyer_id = 0
      buyer_type = ""

      @show.tickets_state("reserved", @quantity, buyer_id, buyer_type)

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

      @show.tickets_state("owned", @quantity, buyer_id, buyer_type)
      

      redirect_to @show.board, :notice => "Enjoy the show!"
      rescue Stripe::CardError => e
        flash[:error] = e.message
        redirect_to root_path
      end
    end
  end

  # def create
  #   if params[:charge_type] == "sb3"
  #     begin
  #     @show = Show.find(params[:show_id])
  #     token = params[:stripeToken]
  #     @quantity = params[:quantity]
  #     # puts "froop" + @quantity.to_s
  #     # puts "frop" + @show.price_adv.to_s
  #     @amount = @show.price_adv.to_i * @quantity.to_i * 10
  #     @board = Board.find_by_vanity_url(params[:board_id])
  #     buyer_id = 0
  #     buyer_type = ""

  #     if current_user.stripe_id
  #       customer = Stripe::Customer.retrieve(current_user.stripe_id)
  #       charge = Stripe::Charge.create(
  #         :customer => customer.id,
  #         :amount => @amount,
  #         :currency => "usd",
  #         :description => @show.id.to_s + " " + @quantity.to_s
  #         )
  #     else
  #       customer = Stripe::Customer.create(
  #         :card => token,
  #         :amount => @amount,
  #         :email => current_user.email,
  #         :description => "Single show ticketing - new"
  #       )

  #       current_user.update_attributes(stripe_id:customer.id)
  #     end

  #     @show.update_attributes(payer_id:current_user.id, paid_at:Time.now)
  #     @show.tickets_make

  #     redirect_to @show.board, :notice => "You have successfully enabled ticketing for this show!"
  #     rescue Stripe::CardError => e
  #       flash[:error] = e.message
  #       redirect_to root_path
  #     end
  #   end
  # end
end

  # def create
  #   if params[:charge_type] == "sb3"
  #     @show = Show.find_by(params[:show_id])
  #     begin

  #     @amount = @show.price_adv

  #     if current_user.stripe_id
  #       customer = Stripe::Customer.retrieve(current_user.stripe_id)
  #       charge = Stripe::Charge.create(
  #         :customer => customer.id,
  #         :amount => @amount,
  #         :currency => "usd",
  #         :description => "Single show ticketing"
  #         )
  #     else
  #       customer = Stripe::Customer.create(
  #         :card => token,
  #         :amount => @amount,
  #         :email => current_user.email,
  #         :description => "Single show ticketing - new"
  #       )

  #       current_user.update_attributes(stripe_id:customer.id)
  #     end

  #     rescue Stripe::CardError => e
  #       flash[:error] = e.message
  #       redirect_to show_path(@show)
  #     end
  #   end
  # end

# def create
#     if params[:charge_type] == "sb2"
#       begin
#       token = params[:stripeToken]

#       @amount = "1000"

#       @board = Board.find_by_vanity_url(params[:board_id])
#       @show = Show.find_by(params[:id])

#       if current_user.stripe_id
#         customer = Stripe::Customer.retrieve(current_user.stripe_id)
#         charge = Stripe::Charge.create(
#           :customer => customer.id,
#           :amount => @amount,
#           :currency => "usd",
#           :description => "Single show ticketing"
#           )
#       else
#         customer = Stripe::Customer.create(
#           :card => token,
#           :amount => @amount,
#           :email => current_user.email,
#           :description => "Single show ticketing - new"
#         )

#         current_user.update_attributes(stripe_id:customer.id)
#       end

#       @show.update_attributes(payer_id:current_user.id, paid_at:Time.now)
#       @show.tickets_make

#       redirect_to @show.board, :notice => "You have successfully enabled ticketing for this show!"
#       rescue Stripe::CardError => e
#         flash[:error] = e.message
#         redirect_to board_charges_path(@board)
#       end
#     end
#   end