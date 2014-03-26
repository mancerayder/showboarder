class ShowsController < ApplicationController

  def new
    @show = Show.new
  end

  def create
    @board = Board.find_by(params[:id])
    if current_user.board_role(@board) == "owner" || current_user.board_role(@board) == "manager"
      @show = @board.shows.new(show_params)
      if @show.save
        flash[:success] = "You have added a show!"
        redirect_to @show
      else
        render 'new'
      end  
    else
      redirect_to root_path
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
      params.require(:show).permit(:state, :datetime_announce, :datetime_door, :datetime_show, :price_adv, :price_door, :pwyw)
    end
end