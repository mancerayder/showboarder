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

  def reserve
    @show = Show.find_by(params[:show_id])
    @quantity = params[:quantity].to_i
    @show.tickets_clear_expired_reservations

    if user_signed_in?
      @show.tickets_reserve(@quantity, current_user.id, current_user.class.to_s)
      redirect_to board_show_checkout_path(@show.board, @show)
    else
      @reserve_code = @show.tickets_reserve(@quantity, nil, nil)
      redirect_to board_show_checkout_path(@show.board, @show, reserve_code:@reserve_code)
    end
  end
end