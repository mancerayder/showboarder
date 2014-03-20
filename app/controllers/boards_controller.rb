class BoardsController < ApplicationController
  def create
    @board = current_user.boards.build(board_params)
  end

  def destroy
  end

  private

    def micropost_params
      params.require(:micropost).permit(:name, :email, :vanity_url)
    end  
end
