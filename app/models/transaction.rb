class Transaction < ActiveRecord::Base
  belongs_to :actioner, polymorphic: true
  belongs_to :actionee, polymorphic: true
end
