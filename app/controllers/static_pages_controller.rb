class StaticPagesController < ApplicationController
  def home
    if user_signed_in?
      @user = current_user
      if @user.boards.count == 1
        @board = @user.boards.first
        # @shows = @board.shows.paginate(page: params[:page])
        @shows = @board.shows.where("show_at > ?", Date.tomorrow).order(:show_at).paginate(page: params[:page])
      end
      # @boards = current_user.boards
      # if @boards.count > 1
      #   @boards = @boards.paginate(page: params[:page])
      # end

      # if @boards.count == 1
      #   @board = @boards.first
      #   @shows = @board.shows.paginate(page: params[:page])
      # end
      render layout: "application"
    else
      render layout: "landing"
    end
  end
end

private

  def guest_params
    params.fetch(:guest, {})
  end