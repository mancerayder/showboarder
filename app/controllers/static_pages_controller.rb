class StaticPagesController < ApplicationController
  def home
    @guest = Guest.new(guest_params)
  end
end

private

  def guest_params
    params.fetch(:guest, {})
  end