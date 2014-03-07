class StaticPagesController < ApplicationController
  def home
    @user = User.new(user_params)
  end
end

private

  def user_params
    params.fetch(:user, {})
  end