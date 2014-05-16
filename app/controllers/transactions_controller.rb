class TransactionsController < ApplicationController
  def reserve
    @show = Show.find_by(params[:show_id])
  end

  def subscribe
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

  def charge
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
      @show.tickets_make

      redirect_to @show.board, :notice => "You have successfully enabled ticketing for this show!"
      rescue Stripe::CardError => e
        flash[:error] = e.message
        redirect_to board_charges_path(@board)
      end
    end
  end  
end
