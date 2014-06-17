class BoardsController < ApplicationController
  load_and_authorize_resource :board, :find_by => :vanity_url


  def new
    @board = Board.new
    @board.stages.build
  end

  def payout
    @board = Board.find_by_vanity_url(params[:board_id])

    if current_user && current_user.boarder?(@board)

    else
      flash[:error] = "Sorry, you must be logged in to an account with management privileges for this board in order to access this page."
      redirect_to @board
    end
  end

  def ticketed
    @board = Board.find_by_vanity_url(params[:board_id])
  end

  def create
    @board = Board.new(board_params)
    # current_user.user_boards.create(:board_id => @board.id)
    if @board.save
      # @stage1.first.name = @board.name
      @board.stages.first.places_gather
      @board.update_attributes(paid_tier:1, state:"public")
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
      params.require(:board).permit(:name, :vanity_url, :places_reference, :paid_tier, {stages_attributes: [:id, :name, :places_reference, :capacity, :board, :places_json ]})
    end
end
