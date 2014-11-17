class Stage < ActiveRecord::Base
  belongs_to :board
  has_many :shows
  has_one :place
  # validates_presence_of :board
  validates :capacity, presence: true

  def places_gather # TODO - wrap self_zone into this
    if self.places_reference?
      @client = GooglePlaces::Client.new(ENV["GOOGLE_SERVER_KEY"])
      spot = @client.spot(self.places_reference)
      self.update_attributes(places_json:spot.to_json)
      @photo1 = nil 
      @photo2 = nil
      @photo3 = nil
      @photo4 = nil
      @photo5 = nil
      @formatted_address = nil
      @formatted_phone_number = nil
      @lat = nil
      @lng = nil
      @international_phone_number = nil
      @name = nil
      @opening_hours = nil
      @price_level = nil
      @rating = nil
      @utc_offset = nil
      @vicinity = nil
      @website = nil
      @reference = nil

      if spot.photos[0] # TODO - make not suck... why did I ever write it like this...?
        @photo1 = spot.photos[0].fetch_url(10000)
      end

      if spot.photos[1]
        @photo2 = spot.photos[1].fetch_url(10000)
      end

      if spot.photos[2]
        @photo3 = spot.photos[2].fetch_url(10000)
      end

      if spot.photos[3]
        @photo4 = spot.photos[3].fetch_url(10000)
      end

      if spot.photos[4]
        @photo5 = spot.photos[4].fetch_url(10000)
      end

      if spot.formatted_address
        @formatted_address = spot.formatted_address
      end

      if spot.formatted_phone_number
        @formatted_phone_number = spot.formatted_phone_number
      end

      if spot.lat
        @lat = spot.lat
      end

      if spot.lng
        @lng = spot.lng
      end

      if spot.international_phone_number
        @international_phone_number = spot.international_phone_number
      end

      if spot.name
        @name = spot.name
      end

      if spot.opening_hours["periods"]
        @opening_hours = spot.opening_hours["periods"].to_json
      end

      if spot.price_level
        @price_level = spot.price_level
      end

      if spot.rating
        @rating = spot.rating
      end

      if spot.utc_offset
        @utc_offset = spot.utc_offset
      end

      if spot.vicinity
        @vicinity = spot.vicinity
      end

      if spot.website
        @website = spot.website
      end

      if spot.reference
        @reference = spot.reference
      end

      self.create_place(formatted_address: @formatted_address, formatted_phone_number: @formatted_phone_number, lat: @lat, lng: @lng, international_phone_number: @international_phone_number, name: @name, opening_hours: @opening_hours, photo1: @photo1, photo2: @photo2, photo3: @photo3, photo4: @photo4, photo5: @photo5, price_level: @price_level, rating: @rating, utc_offset: @utc_offset, vicinity: @vicinity, website: @website, reference: @reference)
    end
  end
end