class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    alias_action :create, :read, :update, :destroy, :to => :crud

    if user.admin?
      can :manage, :all
    end

    can :crud, Board do |board|
      user.user_boards.where(board_id:board.id, role:"manager").length > 0
    end

    can :crud, Board do |board|
      user.user_boards.where(board_id:board.id, role:"owner").length > 0
    end    

    if user.id
        can :create, Board
    end

    can :read, Board, :state => "public"

    can :read, :update, Board do |board|
      user.user_boards.where(board_id:board.id, role:"coordinator").length > 0
    end

    can :crud, Show do |show|
      user.user_boards.where(board_id:show.board_id, role:"manager").length > 0
    end

    can :crud, Show do |show|
      user.user_boards.where(board_id:show.board_id, role:"owner").length > 0
    end

    # can :crud, Show do |show|
    #     user.user_boards.where(board_id:show.board_id, role:"manager").length > 0
    # end

    # can :crud, Show

    can :read, Show, :state => "public"

    # can :crud, Ticket do |ticket|
    #   user.user_boards.where(board_id:ticket.show.board.id, role:"manager").length > 0
    # end

    # can :crud, Ticket do |ticket|
    #   user.user_boards.where(board_id:ticket.show.board.id, role:"owner").length > 0
    # end

    # can :read, Ticket, :user_id => user.id

    # can :crud, :all
    # can :manage, :all


    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/bryanrite/cancancan/wiki/Defining-Abilities
  end
end
