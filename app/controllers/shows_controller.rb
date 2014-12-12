class ShowsController < ApplicationController
  load_and_authorize_resource :board, :find_by => :vanity_url
  load_and_authorize_resource :show, :through => :board

  def new
    @board = Board.find_by_vanity_url(params[:board_id])
    @show = @board.shows.new
    @fb_link = @show.ext_links.build
    @fb_link.ext_site = "Facebook"
  end

  def checkout
    @reserve_code = ""
    @show = Show.find_by_id(params[:show_id])
    @show.tickets_clear_expired_reservations
    if user_signed_in?
      current_user.tickets_clear_expired_reservations
      # @tickets = Ticket.where(ticket_owner_id:current_user.id, ticket_owner_type:current_user.class.to_s, state:"reserved")
      # @tickets = current_user.tickets_retrieve_and_clear_expired
      @tickets = current_user.tickets.where(state:"reserved")
      @cards = current_user.cards_sorted
    else
      @reserve_code = ""
      @tickets = []
      if params[:reserve_code]
        @reserve_code = params[:reserve_code]

        cart = Cart.find_by_reserve_code(@reserve_code)

        carted = cart.tickets

        carted.each do |t| # TODO: DRY this
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
    @show.show_at = ApplicationController.helpers.date_plus_time(params[:show_date], params[:show_time], @board.timezone)
    @show.door_at = ApplicationController.helpers.date_plus_time(params[:show_date], params[:door_time], @board.timezone)
    @show.stage = @board.stages.first

    if @show.ticketing_type == "Sell tickets to the show"
      @show.ticketing_type = "paid"
    else
      @show.ticketing_type = "free"
    end

    if @show.save
      @show.update_attributes(state:"public") # TODO - allow for the creation of pending shows
      @show.acts.each do |e| # loop through all shows acts and merge duplicated acts.
        if e.echonest_id[0..4] == "ECHO-" #this is a check for if the DB query in esuggest was too dumb to find the act in the DB
          temp_echo = e.echonest_id.gsub("ECHO-", "")
          if Act.find_by(echonest_id: temp_echo)
            # TODO: refactor this whole action and mostly make it use the logic in this if case
            e.echonest_id = temp_echo
          end
        end
        if e.echonest_id
          if e.echonest_id[0..2] == "DB-" # found in DB, has no echonest ID = id is "DB-act_id
            dupe = Act.find_by(id: e.echonest_id.gsub("DB-", "").to_i)

            dupe.shows << @show

            e.ext_links.each do |l| # update already-saved act with new act links
              link_uora = dupe.ext_links.find_or_create_by(ext_site:l.ext_site) # uora = updated or added
              link_uora.url = l.url

              link_uora.save!
            end

            e.destroy! # destroy link now that links and show have been merged with existing record
          elsif e.echonest_id[0..4] == "ECHO-" # not found in DB, so ID = "ECHO-echonest_id"
            e.echonest_id = e.echonest_id.gsub("ECHO-", "")
            e.save!
          else # found in db, has echonest ID so id is echonest id
            dupe = Act.find_by(echonest_id: e.echonest_id)

            dupe.shows << @show

            e.ext_links.each do |l| # update already-saved act with new act links
              link_uora = dupe.ext_links.find_or_create_by(ext_site:l.ext_site) # uora = updated or added
              #TODO - remove ext_links that were previously existing and removed
              link_uora.url = l.url unless destroyed?

              link_uora.save!
            end

            e.destroy!
          end
        end
      end
      if @show.ticketing_type == "paid"
        @show.tickets_make
      end
      flash[:success] = "You have added a show!"
      redirect_to [@board, @show]
    else
      render 'new'
    end
  end

  # def ticketed
  #   @board = Board.find_by_vanity_url(params[:board_id])
  #   @show = Show.find_by(params[:id])
  # end

  def checkin
    @show = Show.find(params[:show_id])

    # @attendees = @show.attendees.sort
  end

  def checkin_attendee
    @show = Show.find(params[:show_id])
    @attendee = params[:attendee]

    if @show.checkin_attendee(@attendee["attendee_id"], @attendee["attendee_type"])
      # format.html { redirect_to @user, notice: 'User was successfully created.' }
      # format.js   {}
      render :json => { status: :checked_in }
    else
      # format.html { render action: "new" }
      render :json => { status: :unprocessable_entity }
    end
  end

  def checkout_attendee
    @show = Show.find(params[:show_id])
    @attendee = params[:attendee]

    if @show.checkout_attendee(@attendee["attendee_id"], @attendee["attendee_type"])
      # format.html { redirect_to @user, notice: 'User was successfully created.' }
      # format.js   {}
      render :json => { status: :checkedOut }
    else
      # format.html { render action: "new" }
      format.json { render json: {attendee: @attendee["attendee_id"]}, status: :unprocessable_entity }
    end
  end

  def attendees
    @show = Show.find(params[:show_id])

    attendees = @show.attendees.sort_by do |name|
      name.split(" ").last
    end

    # attendees_checked_in = @show.attendees_checked_in.sort_by do |name|
    #   name.split(" ").last
    # end

    # @all_attendees = [attendees, attendees_checked_in]

    respond_to do |format|
      format.json   { render :json => attendees.to_json }
    end
  end

  def show
    @show = Show.find(params[:id])
    @acts_stringed = @show.acts_stringed
  end

  def update
    @show = Show.find(params[:id])

    @show.show_at = ApplicationController.helpers.date_plus_time(params[:show_date], params[:show_time], @board.timezone)
    @show.door_at = ApplicationController.helpers.date_plus_time(params[:show_date], params[:door_time], @board.timezone)
    if @show.update(show_params) # TODO - allow for editing of google place
      @show.tickets_price_update
      flash[:success] = "Show updated"
      redirect_to board_show_path(@board, @show)
    else
      render 'edit'
    end
  end

  def edit
    @show = Show.find(params[:id])
    @board = @show.board

    if @show.ext_links.count == 0
      @fb_link = @show.ext_links.build
    end
  end

  def destroy
    @show = Show.find(params[:id])
    @board = @show.board
    if @show.tickets_sold != 0
      flash[:error] = "Deletion prevented.  Tickets have already been sold. Email contact@showboarder.com if you need to do this"
      redirect_to @board
    elsif current_user.boarder?(@board)
      board_role = current_user.board_role(@board)
      if board_role == "owner" || board_role == "manager"
        @show.destroy
      end
      flash[:success] = "Show deleted"
      redirect_to @board
    end
  end

  private

    def show_params
      params.require(:show).permit(:state, :error, :announce_at, :door_at, :min_age, :ticketing_type, :show_at, :custom_capacity, :payer_id, :title, :paid_at, :price_adv, :price_door, :board, {ext_links_attributes: [:id, :ext_site, :url, :linkable_type, :_destroy]}, {acts_attributes: [{ext_links_attributes: [:id, :ext_site, :url, :linkable_type, :_destroy]},:id, :name, :email, :echonest_id, :_destroy ]})
    end
end