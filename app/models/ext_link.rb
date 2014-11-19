class ExtLink < ActiveRecord::Base
  belongs_to :linkable, polymorphic: true
  validates :url, presence: true
  validates :ext_site, presence: true
  before_save { 
    if self.url
      self.url = PostRank::URI.clean(url)
    end
  }

end
