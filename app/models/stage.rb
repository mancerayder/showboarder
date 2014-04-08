class Stage < ActiveRecord::Base
  belongs_to :board
  has_many :shows
  # validates_presence_of :board

  def places_gather
    @client = GooglePlaces::Client.new(ENV["GOOGLE_KEY"])
    spot = @client.spot(self.places_reference)
    self.update_attributes(places_json:spot.to_json)
  end
end
