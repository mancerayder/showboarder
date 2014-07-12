class Charge < ActiveRecord::Base
  belongs_to :sale
  belongs_to :actioner, polymorphic: true
  belongs_to :actionee, polymorphic: true
  has_paper_trail

  include AASM

  aasm column: 'state', skip_validation_on_save: true do
    state :charged, initial: true
    state :refunded

    event :refund, after: :send_refund_email do
      transitions from: :finished, to: :refunded
    end
  end

  def send_refund_email
    ReceiptMailer.delay.refund(self.id)
    AdminMailer.delay.refund(self.id)
  end
end