class BoardsController < ApplicationController
  before_filter :authenticate_user!

  def new
    @board = Board.new
  end

  def create
    @board = Board.new(board_params)
    # current_user.user_boards.create(:board_id => @board.id)

    if @board.save
      current_user.boarder!(@board, "owner")
      flash[:success] = "You have created a new Showboard!"
      redirect_to @board
    else
      render 'new'
    end    
  end

  def show
    @board = Board.find_by_vanity_url(params[:id])
    @shows = @board.shows.paginate(page: params[:page])
  end

  def destroy
    @board = Board.find_by_vanity_url(params[:id])
    if current_user.board_role(@board) == "owner"
      @board.destroy
      flash[:success] = "You have deleted #{@board.name}!"
    else
      flash[:error] = "Sorry, you are not the owner of #{@board.name} and therefore you cannot delete it!"
    end
    redirect_to root_path
  end

  private

    def board_params
      params.require(:board).permit(:name, :vanity_url)
    end
end
