class ShowsController < ApplicationController
  load_and_authorize_resource :board, :find_by => :vanity_url
  load_and_authorize_resource :show, :through => :board

  def new
    @board = Board.find_by_vanity_url(params[:board_id])
    @show = @board.shows.new
  end

  def checkout
    @show = Show.find_by(params[:id])
    @show.tickets_clear_expired_reservations
    if user_signed_in?
      @tickets = Ticket.where(ticket_owner_id:current_user.id, ticket_owner_type:current_user.class.to_s, state:"reserved")
      # tickets.each do |t|
      #   if t.expired?
      #     t.make_open
      #   end
      # end
      # @tickets = Ticket.where(ticket_owner_id:current_user.id, ticket_owner_type:current_user.class.to_s)
    else
      @reserve_code = ""
      @tickets = []
      if params[:reserve_code]
        @reserve_code = params[:reserve_code]
        @reserve_code.split("-").each do |c|
          t = Ticket.where(show_id:c.split("_")[1].to_i, reserve_code:c).first
          if t && !t.expired?
            @tickets << t
          elsif t
            t.make_open("Reservation expired before state change")
          else
            next
          end
        end
      end
      
    end
    @amount = 0

    @tickets.each do |t|
      @amount = @amount + t.price
    end

    if @amount == 0
      redirect_to board_show_path(@show.board, @show)
    end
  end

  def create
    @board = Board.find_by_vanity_url(params[:board_id])
    @show = @board.shows.new(show_params)
    @show.stage = @board.stages.first
    if @show.save
      @show.update_attributes(ticketed:true, state:"public")
      if @show.ticketed
        @show.tickets_make
      end
      flash[:success] = "You have added a show!"
      redirect_to [@board, @show]
    else
      render 'new'
    end
  end

  def charge
    @board = Board.find_by_vanity_url(params[:board_id])
    @show = Show.find_by(params[:id])
  end

  def show
    @show = Show.find(params[:id])
  end

  def update
  end

  def destroy
  end

  private

    def show_params
      params.require(:show).permit(:state, :datetime_announce, :datetime_door, :datetime_show, :price_adv, :price_door, :board, :pwyw)
    end
end