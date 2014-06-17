class PaymentsWorker

  include Sidekiq::Worker

  def perform(guid)
    ActiveRecord::Base.connection_pool.with_connection do
      transaction = Transaction.find_by!(guid: guid)
      transaction.process!
    end
  end
end