class Place < ActiveRecord::Base
  belongs_to :stage, dependent: :destroy
end
