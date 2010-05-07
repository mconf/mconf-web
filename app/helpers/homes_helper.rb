module HomesHelper
  
  def select_periods(events)
    # these are the times to use
    now = Time.now.gmtime
    end_of_today = Time.now.in_time_zone.end_of_day.gmtime
    end_of_tomorrow = end_of_today + 1.day
    end_of_week = Time.now.in_time_zone.end_of_week.gmtime
    end_of_30_days = end_of_today + 29.days
    end_of_60_days = end_of_today + 59.days
      
    today_events = select_period(events, now, end_of_today)

    tomorrow_events = select_period(events, end_of_today, end_of_tomorrow) 
      
    week_events = select_period(events, end_of_tomorrow, end_of_week)

    upcoming_events = select_period(events, end_of_week, end_of_30_days)

    if upcoming_events.size<2
      upcoming_events = select_period(events, end_of_week, end_of_60_days) 
    end
    
    return [["today",today_events], ["tomorrow",tomorrow_events], ["week.this",week_events], ["event.upcoming.other",upcoming_events]]
  end

  def select_period(set_of_events, start_datetime, end_datetime)
    return set_of_events.select{|e| e.has_date? && (start_datetime < e.start_date.gmtime) && (e.start_date.gmtime < end_datetime)}
  end
  
  def intervals(contents)
    today = {:contents => contents.select{|x| x.updated_at > Date.yesterday}, :name => t('today')}
    yesterday = {:contents => contents.select{|x| x.updated_at > Date.yesterday - 1 && x.updated_at < Date.yesterday}, :name => t('yesterday')}
    last_week = {:contents => contents.select{|x| x.updated_at > Date.today - 7 && x.updated_at < Date.yesterday - 1}, :name => t('last_week')}
    older = {:contents => contents.select{|x| x.updated_at < Date.today - 7}, :name => t('older')}
  
    intervals = [today, yesterday, last_week, older]
  end
  
  def path_for_home(p={})
    per_page = p[:per_page].present? ? p[:per_page] : params[:per_page]
    contents = (params[:contents].present? ? params[:contents].split(",") : Space.contents.map(&:to_s)) + [p[:add_content]] -[p[:rm_content]]
    
    url_for(:per_page => per_page, :contents => contents.join(","))
  end
  
  def home_menu_checkbox(name)
    check_box_tag name, name , @contents.map(&:to_s).include?(name), :class => 'home_menu_checkbox' 
  end
  
  
end