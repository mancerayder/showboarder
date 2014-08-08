class ExtLink < ActiveRecord::Base
  belongs_to :linkable, polymorphic: true
end
