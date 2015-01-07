class EmailSubscription < ActiveRecord::Base
	belongs_to :email_subscriber, :polymorphic => true
	belongs_to :board
end