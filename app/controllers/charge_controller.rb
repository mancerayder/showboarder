class ChargeController < ApplicationController
  load_and_authorize_resource :board, :find_by => :vanity_url
  load_and_authorize_resource :show

  def new
    @board = Board.find_by_vanity_url(params[:board_id])
    @show = Show.find_by(params[:id])
  end

  def create
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
          :description => "Single show ticketing"
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
