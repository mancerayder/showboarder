class Act < ActiveRecord::Base
  has_and_belongs_to_many :shows
  has_many :ext_links, as: :linkable, dependent: :destroy
  before_save { if email != nil && email != ""
                  email.downcase!
                end }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, format:     { with: VALID_EMAIL_REGEX },
                    allow_blank: true,
                    uniqueness: { case_sensitive: false }
  accepts_nested_attributes_for :ext_links, :reject_if => :all_blank, :allow_destroy => true

  def self.echo_by_name(name, eid)
    data = {}
    num_urls = {}

    if eid[0..2] == "DB-" # found in DB, has no echonest ID = id is "DB-act_id
      artist = Act.find_by(id: eid.gsub("DB-", "").to_i)

      artist.ext_links.each do |e|
        site_to_num = 0

        if e.ext_site == "Homepage"
          # site_to_num stays 0
        elsif e.ext_site == "Lastfm"
          site_to_num = 1
        elsif e.ext_site == "Twitter"
          site_to_num = 2
        elsif e.ext_site == "Myspace"
          site_to_num = 3
        elsif e.ext_site == "Wikipedia"
          site_to_num = 4
        elsif e.ext_site == "Musicbrainz"
          site_to_num = 5
        end

        num_urls[site_to_num] = e.url
      end

    elsif eid[0..4] == "ECHO-" # not found in DB = ID = "ECHO-echonest_id"

      artist = Act.find_by(echonest_id: eid.gsub("ECHO-", ""))

      artist.ext_links.each do |e|
        site_to_num = 0

        if e.ext_site == "Homepage"
          # site_to_num stays 0
        elsif e.ext_site == "Lastfm"
          site_to_num = 1
        elsif e.ext_site == "Twitter"
          site_to_num = 2
        elsif e.ext_site == "Myspace"
          site_to_num = 3
        elsif e.ext_site == "Wikipedia"
          site_to_num = 4
        elsif e.ext_site == "Musicbrainz"
          site_to_num = 5
        end

        num_urls[site_to_num] = e.url
      end

    else # found in db, has echonest ID = id is echonest id
      artist = Echowrap.artist_search(:name => name, bucket: 'urls').first

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
    end
    data = data.merge(name: name,
                      # urls: artist.urls,
                      urls: num_urls)
    return data
    
  end
end
