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
end
