class BoardsController < ApplicationController
  before_filter :authenticate_user!

  def new
    @board = current_user.boards.new
  end

  def create
    @board = Board.new(board_params)
    current_user.user_boards.build(board_id: @board.id)
    # current_user.boarder!(@board)
    if @board.save
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
      params.require(:board).permit(:name)
    end
end
