class GuestsController < ApplicationController
  def new
    @guest = Guest.new
  end

  def create
    @guest = Guest.new(guest_params)
    if @guest.save
      redirect_to root_path
    else
      render 'static_pages/home'
    end
  end

 private

    def guest_params
      params.require(:guest).permit(:email)
    end
end
