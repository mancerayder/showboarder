module ApplicationHelper
  def number_to_stripe(stored)
    return (stored * 100).to_i
  end

  def just_month_year(date)
    jmy = ""
    jmy = jmy + date.month.to_s + "/" + date.year.to_s
    return jmy
  end
end
