class UserBoardsController < ApplicationController
  before_filter :authenticate_user!

  # def create
  #   @board = Board.find(params[:user_board][:board_id])
  #   current_user.boarder!(@board)
  #   respond_to do |format|
  #     format.html { redirect_to @board }
  #     format.js
  #   end
  # end

  # def destroy
  #   @board = Show_Board.find(params[:id]).board
  #   current_user.unboard!(@board)
  #   respond_to do |format|
  #     format.html { redirect_to @board }
  #     format.js
  #   end
  # end
end