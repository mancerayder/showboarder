class Show < ActiveRecord::Base
  belongs_to :stage, dependent: :destroy
  belongs_to :board, dependent: :destroy
end
