class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    alias_action :create, :read, :update, :destroy, :to => :crud

    if user.admin?
      can :manage, :all
    end

    can :read, Board, :state => "public"

    can :read, Show, :state => "public"

    can :manage, Board do |board|
      user.user_boards.where(board_id:board.id, role:"manager").length > 0
    end

    if user.id
      can :create, Board
    end

    can :manage, Board do |board|
      user.user_boards.where(board_id:board.id, role:"owner").length > 0
    end

    can :read, :update, Board do |board|
      user.user_boards.where(board_id:board.id, role:"manager").length > 0
    end

    can :manage, Show do |show|
      user.user_boards.where(board_id:show.board_id, role:"manager").length > 0
    end

    can :manage, Show do |show|
      user.user_boards.where(board_id:show.board_id, role:"owner").length > 0
    end

    can :crud, Ticket do |ticket|
      user.user_boards.where(board_id:ticket.show.board_id, role:"owner").length > 0
    end

    can :crud, Ticket do |ticket|
      user.user_boards.where(board_id:ticket.show.board_id, role:"manager").length > 0
    end

    can :crud, Ticket do |ticket|
      ticket.ticket_owner == user
    end
  end
end
