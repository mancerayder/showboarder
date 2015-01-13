class BoardsController < ApplicationController
  load_and_authorize_resource :board, :find_by => :vanity_url, :except => [:new]

  def new
    if !user_signed_in?
      redirect_to new_user_registration_path(:path_from => "create_board")
    else
      @board = Board.new
      @stage = @board.stages.build
    end
  end

  def edit
    @board = Board.find_by_vanity_url(params[:id])
    @stage = @board.stages.first
  end

  def update
    @board = Board.find_by_vanity_url(params[:id])
    @stage = @board.stages.first

    if @board.update(board_params) # TODO - allow for editing of google place
      flash[:success] = "Board updated"
      redirect_to @board
    else
      render 'edit'
    end
  end

  def ticketed
    #TODO Find out if/why this is getting called twice 
    @board = Board.find_by_vanity_url(params[:board_id])

    if user_signed_in? and !current_user.stripe_recipient_id
      redirect_to user_stripe_connect_path(current_user) and return
    elsif user_signed_in? and current_user.boarder?(@board) and (current_user.board_role(@board) == "manager") and current_user.stripe_recipient_id 
      current_user.board_role_assign(@board, "owner")
      @board.update(paid_tier: 1)

      flash[:success] = "Ticketing is now enabled for this showboard!" # TODO find out why this isn't showing
    else
      # TODO: re-implement this once double calling is fixed.
      # flash[:error] = "Sorry, you do not have significant permissions to complete this action."
    end
    redirect_to board_path(@board)
  end

  def create
    @board = Board.new(board_params)
    puts board_params
    if @board.save
      AdminMailer.delay.new_board(@board.id)
      puts @board.ext_links.count
      @board.stages.each do |s|
        s.places_gather
      end
      @board.self_zone
      @board.update_attributes(state:"public")
      current_user.boarder!(@board, "manager")
      flash[:success] = "You have created a new Showboard!"
      redirect_to @board
    else
      render 'boards/new'
    end
  end

  def show
    @board = Board.find_by_vanity_url(params[:id])

    @shows = @board.shows.where("show_at > ?", Date.tomorrow).order(:show_at).paginate(page: params[:page])
  end

  def destroy
    @board = Board.find_by_vanity_url(params[:id])
    @board.destroy
    flash[:success] = "You have deleted #{@board.name}!"
    redirect_to root_path
  end

  private

    def board_params
      params.require(:board).permit(:id, :name, :vanity_url, :header_image, :places_reference, :email, :paid_tier, :state, :ext_links_attributes => [:id, :board_id, :ext_site, :url, :linkable_type, :_destroy], :stages_attributes => [:id, :board_id, :name, :places_reference, :capacity, :places_json, :_destroy, :places_formatted_address_short])
    end
end
