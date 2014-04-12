class ShowsController < ApplicationController
  load_and_authorize_resource :board, :find_by => :vanity_url
  load_and_authorize_resource :show, :through => :board

  def new
    @board = Board.find_by_vanity_url(params[:board_id])
    @show = @board.shows.new
    puts @show.board_id
  end

  def create
    @board = Board.find_by_vanity_url(params[:board_id])
    @show = @board.shows.new(show_params)
    @show.stage = @board.stages.first
    if @show.save
      @show.make_tickets
      flash[:success] = "You have added a show!"
      redirect_to [@board, @show]
    else
      render 'new'
    end
  end

  def show
    @show = Show.find(params[:id])
  end

  def update
  end

  def destroy
  end

  private

    def show_params
      params.require(:show).permit(:state, :datetime_announce, :datetime_door, :datetime_show, :price_adv, :price_door, :board, :pwyw)
    end
end