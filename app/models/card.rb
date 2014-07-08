class Card < ActiveRecord::Base
  belongs_to :user

  def default?
    if self.stripe_id == self.user.stripe_default_card
      return true
    else
      return false
    end
  end
  
  def image
    img = ""
    if brand == "visa"
      img = asset_path('visa.png')
    elsif brand == "mastercard"
      img = asset_path('mastercard.png')
    elsif brand == "discover"
      img = asset_path('discover.png')
    elsif brand == "amex"
      img = asset_path('amex.png')
    elsif brand == "dinersclub"
      img = asset_path('dinersclub.png')
    elsif brand == "maestro"
      img = asset_path('maestro.png')
    else
      img = asset_path('laser.png')
    end
    return img
  end
end