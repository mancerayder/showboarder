class TicketsController < ApplicationController
  load_and_authorize_resource :board, :find_by => :vanity_url
  load_and_authorize_resource :show, :through => :board
  load_and_authorize_resource :ticket, :through => :show

  def new
    @show = Show.find_by(params[:show_id])
    @ticket = @show.tickets.new
  end

  def create

  end
end