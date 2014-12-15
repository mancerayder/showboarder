class UsersController < ApplicationController
  def stripe_connect
    @user = current_user
  end

  def show
    @user = current_user
  end
end
