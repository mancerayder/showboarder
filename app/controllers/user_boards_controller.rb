class UserBoardsController < ApplicationController
  before_action :signed_in_user

  def create
    @board = Board.find(params[:user_board][:board_id])
    current_user.boarder!(@board)
    respond_to do |format|
      format.html { redirect_to @board }
      format.js
    end
  end

  def destroy
    @board = User_Board.find(params[:id]).board_id
    current_user.unboard!(@board)
    respond_to do |format|
      format.html { redirect_to @board }
      format.js
    end
  end  
end
