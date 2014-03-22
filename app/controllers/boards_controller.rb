class BoardsController < ApplicationController
  def new
    @board = current_user.boards.new
  end

  def create
    @board = Board.new(board_params)
    if @board.save
      flash[:success] = "You have created a new Showboard!"
      redirect_to @board
    else
      render 'new'
    end    
  end

  private

    def board_params
      params.require(:board).permit(:name)
    end
end
