class CardsWorker

  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(guid)
    ActiveRecord::Base.connection_pool.with_connection do
      card = Card.find_by!(guid:guid)
      card.process!
    end
  end
end