class Stage < ActiveRecord::Base
  belongs_to :board
  has_many :shows
  
end
