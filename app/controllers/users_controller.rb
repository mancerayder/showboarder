class UsersController < ApplicationController
#   def new
#     @user = User.new
#   end

  def stripe_connect
    @user = current_user
  end

  # def boards
  #   @boards = current_user.boards.paginate(page: params[:page])
  # end

  # def edit
  #   @user = current_user
  # end

  # def update
  # end

  def show
    @user = current_user
  end

#   def create
#     @user = User.new(user_params)
#     if @user.save
#       # sign_in @user
#       # UserMailer.beta_welcome(@user).deliver
#       AdminMailer.beta_application(@user).deliver
#       flash[:success] = "Thank you for submitting your application! The Showboarder team will contact you soon with more information about the beta!"
#       redirect_to root_path
#     else
#       render 'static_pages/home'
#       # redirect_to root_path
#     end
#   end

# private

#   def user_params
#     params.require(:user).permit(:email, :password, :password_confirmation)
#   end
end
