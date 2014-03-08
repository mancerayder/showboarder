class GuestsController < ApplicationController
  def new
    @guest = Guest.new
  end

  def create
    @guest = Guest.new(guest_params)
    if @guest.save
      # sign_in @user
      UserMailer.beta_welcome_email(@guest).deliver
      AdminMailer.beta_application(@guest).deliver
      flash[:success] = "Thank you for submitting your application! The Showboarder team will contact you soon with more information about the beta!"
      redirect_to root_path
    else
      render 'static_pages/home'
      # redirect_to root_path
    end
  end

 private

    def guest_params
      params.require(:guest).permit(:email)
    end
end
