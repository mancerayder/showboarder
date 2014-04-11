class SubscribeController < ApplicationController
  load_and_authorize_resource :board, :find_by => :vanity_url


  def new
    @board = Board.find_by_vanity_url(params[:board_id])
  end

  def create
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

  # def new
  # end

  # def create
  #   # Amount in cents
  #   @amount = 500

  #   customer = Stripe::Customer.create(
  #     :email => 'example@stripe.com',
  #     :card  => params[:stripeToken]
  #   )

  #   charge = Stripe::Charge.create(
  #     :customer    => customer.id,
  #     :amount      => @amount,
  #     :description => 'Rails Stripe customer',
  #     :currency    => 'usd'
  #   )

  # rescue Stripe::CardError => e
  #   flash[:error] = e.message
  #   redirect_to charges_path
  # end
end
