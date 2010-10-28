module AgendasHelper
  def agenda_date(event)
    if event.start_date.year != event.end_date.year
      "#{event.start_date.strftime("%B %Y")} - #{event.end_date.strftime("%B %Y")}"
    elsif event.start_date.month != event.end_date.month
      "#{event.start_date.strftime("%B")} - #{event.end_date.strftime("%B %Y")}"
    else
      event.start_date.strftime("%B %Y")
    end 
  end
  
  def edit_agenda_day_links(event)
    html = ""
    for i in (1..@event.days)
      agenda_day = event.start_date + (i-1).day
      if i!=1
        html << link_to(agenda_day.strftime("%a %d"), edit_space_event_agenda_path(@space, @event, :day => i), :class => "agenda_day_link")
      else
        html << link_to(agenda_day.strftime("%a %d"), edit_space_event_agenda_path(@space, @event, :day => i), :class => "agenda_day_link first_day_link")
      end
    end
    html
  end
  
end