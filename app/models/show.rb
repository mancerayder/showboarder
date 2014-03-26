class Show < ActiveRecord::Base
  belongs_to :board
  has_and_belongs_to_many :stages

end
