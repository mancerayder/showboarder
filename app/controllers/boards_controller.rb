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
    @board = Board.find(params[:id])
  end

  private

    def board_params
      params.require(:board).permit(:name, :boarder)
    end
end
