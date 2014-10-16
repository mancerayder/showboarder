class StaticPagesController < ApplicationController
  def home
    if user_signed_in?
      @user = current_user
      if @user.boards.count > 1
        @boards = @user.boards.paginate(page: params[:page])
      end
      if @user.boards.count == 1
        @board = @user.boards.first
        @shows = @board.shows.paginate(page: params[:page])
      end
      # @boards_paginated = []
      # @boards.each do |p|
      #   @boards_paginated << p.paginate(page: params[:page])
      # end
    end
    render :layout => "home"
  end

  def about
  end
end

private

  def guest_params
    params.fetch(:guest, {})
  end