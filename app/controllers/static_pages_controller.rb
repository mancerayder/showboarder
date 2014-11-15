class StaticPagesController < ApplicationController
  def home
    if user_signed_in?
      @user = current_user
      if @user.boards.count == 1
        @board = @user.boards.first
        @shows = @board.shows.paginate(page: params[:page])
      end
      # @boards = current_user.boards
      # if @boards.count > 1
      #   @boards = @boards.paginate(page: params[:page])
      # end

      # if @boards.count == 1
      #   @board = @boards.first
      #   @shows = @board.shows.paginate(page: params[:page])
      # end
      render layout: "landing"
    else
      render layout: "landing"
    end
  end

  def about
  end
end

private

  def guest_params
    params.fetch(:guest, {})
  end