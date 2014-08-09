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
    @card = Card.new
    @checkout_type = "Cart"
    if user_signed_in?
      @tickets = Ticket.where(ticket_owner_id:current_user.id, ticket_owner_type:current_user.class.to_s, state:"reserved")
      @cards = current_user.cards_sorted
    else
      @reserve_code = ""
      @tickets = []
      if params[:reserve_code]
        @reserve_code = params[:reserve_code]

        cart = Cart.find_by_reserve_code(@reserve_code)

        carted = cart.tickets

        carted.each do |t|
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

    if @tickets.count == 0
      redirect_to board_show_path(@show.board, @show)
    end

    @sale = Sale.new
  end

  def create
    @board = Board.find_by_vanity_url(params[:board_id])
    @show = @board.shows.new(show_params)
    # @act = @show.acts.build(show_params["acts_attributes"])
    @show.stage = @board.stages.first
    if @show.ticketing_type == "Ticketed"
      @show.ticketing_type = "paid"
    else
      @show.ticketing_type = "free"
    end
    if @show.save
      @show.update_attributes(state:"public") # change this later to allow for the creation of pending shows
      @show.tickets_make
      flash[:success] = "You have added a show!"
      redirect_to [@board, @show]
    else
      render 'new'
    end
  end

  def ticketed
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
      params.require(:show).permit(:state, :error, :announce_at, :door_at, :ticketing_type, :show_at, :custom_capacity, :payer_id, :paid_at, :price_adv, :price_door, :board, {acts_attributes: [{ext_links_attributes: [:id, :ext_site, :url, :type]},:id, :name, :musicbrainz_id, :email, :_destroy ]})
    end
end