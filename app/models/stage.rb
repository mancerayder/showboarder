class Stage < ActiveRecord::Base
  belongs_to :board
  has_many :shows
  # validates_presence_of :board
end
