class PaymentsWorker

  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(guid)
    ActiveRecord::Base.connection_pool.with_connection do
      sale = Sale.find_by!(guid: guid)
      sale.process!
    end
  end
end