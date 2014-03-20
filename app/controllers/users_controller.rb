class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # sign_in @user
      # UserMailer.beta_welcome_email(@user).deliver
      AdminMailer.beta_application(@user).deliver
      flash[:success] = "Thank you for submitting your application! The Showboarder team will contact you soon with more information about the beta!"
      redirect_to root_path
    else
      render 'static_pages/home'
      # redirect_to root_path
    end
  end

  def boarder!(board, role)
    user_board.create!(board_id: board.id, role:role)
  end

  def boarder?(board)
    user_board.find_by(board_id: board.id)
  end

  def unboard!(board)
    user_board.find_by(board_id: board.id).destroy
  end

  def board_role(board)
    user_board
  end

  def boards
    Board.from_boards_boarded_by(self)
  end
private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
