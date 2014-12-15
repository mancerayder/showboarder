class StaticPagesController < ApplicationController
  def home
    if user_signed_in?
      @user = current_user
      if @user.boards.count == 1
        @board = @user.boards.first
        @shows = @board.shows.where("show_at > ?", Date.tomorrow).order(:show_at).paginate(page: params[:page])
      end
      @tickets_by_show = @user.tickets_by_show

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