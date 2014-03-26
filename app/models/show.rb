class Show < ActiveRecord::Base
  belongs_to :stage
  belongs_to :board
end
