class ApplicationController < ActionController::Base
  def new
    @card = Card.new
  end

  def create
    token = params[:stripeToken]

    @card = Card.new(stripe_token:token, user:current_user)

    if @card.save
      @card.queue_job!
      render json: { guid: @card.guid }
    else
      render json: { error: @card.errors.full_messages.join(". ") }, status: 400
    end  
  end
end