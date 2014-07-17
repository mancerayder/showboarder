class CardsController < ActionController::Base
  def new
    @card = Card.new
  end

  def status
    @card = Card.where(guid: params[:guid]).first
    render nothing: true, status: 404 and return unless @card
    render json: {guid: @card.guid, status: @card.state, error: @card.error}
  end  

  def create
    token = params[:stripeCardToken]

    @card = Card.new(stripe_token:token, user:current_user)

    if @card.save
      @card.queue_job!
      render json: { guid: @card.guid }
    else
      render json: { error: @card.errors.full_messages.join(". ") }, status: 400
    end  
  end
end