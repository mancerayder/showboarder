class Act < ActiveRecord::Base
  has_and_belongs_to_many :shows
  has_many :ext_links, as: :linkable
  before_save { if email != nil && email != ""
                  email.downcase!
                end }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, format:     { with: VALID_EMAIL_REGEX },
                    allow_blank: true,
                    uniqueness: { case_sensitive: false }
  accepts_nested_attributes_for :ext_links, :reject_if => :all_blank, :allow_destroy => true

  def self.echo_by_name(name)
    data = {}
    num_urls = {}
    # yt_only = []
    artist = Echowrap.artist_search(:name => name, bucket: 'urls').first

    # JSON.parse(artist.urls.to_json).each do |u|
    #   num_urls.merge(JSON.parse(u.to_json))
    # end

    JSON.parse(artist.urls.to_json).each do |u|
      if u[0] == "official_url"
        # u[0] = 0
        num_urls[0] = u[1]
      elsif u[0] == "lastfm_url"
        num_urls[1] = u[1]
      elsif u[0] == "twitter_url"
        num_urls[2] = u[1]
      elsif u[0] == "myspace_url"
        num_urls[3] = u[1]
      elsif u[0] == "wikipedia_url"
        num_urls[4] = u[1]
      elsif u[0] == "mb_url"
        num_urls[5] = u[1]
      else
        num_urls[u[0]] = u[1]
      end

    end

    # artist.video.each do |v|
    #   if v.site == "youtube.com"
    #     yt_only << v
    #   end
    # end

    data = data.merge(name: name,
                      # urls: artist.urls,
                      urls: num_urls)
    return data
  end

  # def echo_by_id(id)
  #   data = {}

  #   data.merge(:urls => Echowrap.

  # end
end
