class UserBoardsController < ApplicationController
  before_filter :authenticate_user!
end