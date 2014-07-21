class CardsController < ActionController::Base
  def new
    @card = Card.new
  end

  def show
    @card = Card.find_by(guid: params[:guid])
    respond_to do |format|
      format.js   {}
    end
  end

  def status
    @card = Card.find_by(guid: params[:guid])
    render nothing: true, status: 404 and return unless @card
    render json: {guid: @card.guid, status: @card.state, error: @card.error}
    # if @card.state == "confirmed"
    #   flash[:success] = "card added yo!"
    # end
  end  

  def create
    token = params[:stripeCardToken]

    @card = Card.new(stripe_token:token, user:current_user)

    if @card.save
      @guid = @card.guid
      @card.queue_job!
      render json: { guid: @card.guid }
    else
      render json: { error: @card.errors.full_messages.join(". ") }, status: 400
    end  
  end
end