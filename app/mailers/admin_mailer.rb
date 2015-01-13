class AdminMailer < ActionMailer::Base
  default to: 'admin@showboarder.com',
          from: 'admin@showboarder.com'

  def new_user(user)
    @user = User.find_by_id(user)
    mail(subject: "New user #{@user.email}")
  end

  def dispute(charge_id)
    @charge = Charge.find_by_id(charge_id)
    @sale = charge.sale
    mail(subject: "ALERT: Charge Disputed!")
  end

  def past_due(charge_id)
  end

  def receipt(guid)
    @sale = Sale.find_by(guid: guid)
    @tickets = @sale.actionee.tickets
    @show = @sale.actionee.tickets.first.show

    if @sale
      mail(subject: "Ticket/s sold!")
    end
  end

  def new_board(board)
    @board = Board.find_by_id(board)

    if @board
      mail(subject: "New Board!")
    end
  end
end