class BoardsController < ApplicationController
  load_and_authorize_resource :board, :find_by => :vanity_url

  def new
    @board = Board.new
    @stage = @board.stages.build
  end

  def edit
    @board = Board.find_by_vanity_url(params[:id])
    @stage = @board.stages.first
  end

  def update
    @board = Board.find_by_vanity_url(params[:id])
    @stage = @board.stages.first
  end

  # def payout
  #   @board = Board.find_by_vanity_url(params[:board_id])

  #   if current_user && current_user.boarder?(@board)

  #   else
  #     flash[:error] = "Sorry, you must be logged in to an account with management privileges for this board in order to access this page."
  #     redirect_to @board
  #   end
  # end

  # def ticketed
  #   @sale = Sale.new
  #   @amount = 2500
  #   @board = Board.find_by_vanity_url(params[:board_id])
  #   @actionee_type = "board"
  #   if user_signed_in?
  #     @cards = current_user.cards_sorted
  #   end
  # end

  def simple_ticketed
    #TODO Find out why this is getting called twice 
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
    # the following was a bad way of handling permissions.  TODO: break this out into cancancan
    # if user_signed_in? && current_user.boarder?(@board) && current_user.board_role(@board) == "manager" && current_user.stripe_recipient_id
    #   flash[:success] = "Ticketing is now enabled for this showboard!"
    #   current_user.boarder!(@board, "owner")
    #   @board.update(paid_tier: 1)
    #   redirect_to @board
    # elsif user_signed_in?
    #   redirect_to user_stripe_connect_path(current_user)
    # else
    #   flash[:error] = "You must be signed in and have control over this board to enable ticketing."
    #   redirect_to new_user_session_path
    # end
  end

  def create
    @board = Board.new(board_params)
    # current_user.user_boards.create(:board_id => @board.id)
    if @board.save
      # @stage1.first.name = @board.name
      @board.stages.each do |s|
        s.places_gather
      end
      @board.self_zone
      # @board.update_attributes(state:"public")
      current_user.boarder!(@board, "manager")
      flash[:success] = "You have created a new Showboard!"
      redirect_to @board
    else
      render 'boards/new'
    end    
  end

  def show
    @board = Board.find_by_vanity_url(params[:id])
    @shows = @board.shows.paginate(page: params[:page])
  end

  def destroy
    @board = Board.find_by_vanity_url(params[:id])
    @board.destroy
    flash[:success] = "You have deleted #{@board.name}!"
    redirect_to root_path
  end

  private

    def board_params
      params.require(:board).permit(:name, :vanity_url, :places_reference, :paid_tier, {stages_attributes: [:id, :name, :places_reference, :capacity, :board, :places_json, :_destroy ]})
    end
end
