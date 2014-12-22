module ApplicationHelper
  def number_to_stripe(stored)
    return (stored * 100).to_i
  end

  def int_formatted_price(amount)
    sprintf("$%0.2f", (amount || 0) / 100.0)
  end

  def just_month_year(date)
    jmy = ""
    jmy = jmy + date.month.to_s + "/" + date.year.to_s
    return jmy
  end
  
  def date_plus_time(d, t, z)
    date = Date.strptime(d, "%m/%d/%Y")
    zone = ActiveSupport::TimeZone[z]
    twz = zone.parse(date.to_s + " " + t)
    return twz
  end
end
