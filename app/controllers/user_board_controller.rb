class UserBoardController < ApplicationController
  before_filter :authenticate_user!

  def create
    @board = User.find(params[:user_board][:board_id])
    current_user.boarder!(@board, [:role])

  end

  def destroy
  end
end
