class Ticket < ActiveRecord::Base
  belongs_to :user, dependent: :destroy
  belongs_to :show, dependent: :destroy
  belongs_to :referral_band

  def buy_or_die
    if self.state == "reserved"
      self.update_attributes(state:"open")
    end
  end
end
