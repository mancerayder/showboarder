class Subscription < ActiveRecord::Base
  belongs_to :sale
  belongs_to :board
  has_paper_trail

  include AASM

  aasm column: 'state', skip_validation_on_save: true do
    state :trialing, initial: true
    state :active
    state :past_due
    state :canceled
    state :unpaid

    event :trial_end do
      transitions from: :trialing, to: :active
    end

    event :cancel, after: :send_cancellation_email do
      transitions from: :active, to: :canceled
    end

    event :past_due, after: :send_past_due_email do
      transitions from: :active, to: :past_due
    end

    event :unpaid do
      transitions from: :active, to: :unpaid
    end
  end

  def send_cancellation_email #todo
    ReceiptMailer.delay.cancellation(self.id)
    AdminMailer.delay.cancellation(self.id)
  end

  def send_past_due_email #todo
    ReceiptMailer.delay.cancellation(self.id)
    AdminMailer.delay.cancellation(self.id)
  end
end