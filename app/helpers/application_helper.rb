module ApplicationHelper
  def number_to_stripe(stored)
    return (stored * 100).to_i
  end
end
