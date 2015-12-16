module EventsHelper

  def event_logo(event, options={})
    options[:class] = "#{options[:class]} event-logo"

    day = sanitize(event.start_on.strftime("%d"))
    month = localize(event.start_on, :format => "%b")
    hour = event.get_formatted_hour
    year = sanitize(event.start_on.strftime("%Y"))

    hour_tag = content_tag(:div, hour, { :class => 'event-logo-hour' })
    day_tag = content_tag(:div, day + ' ' + month, { :class => 'event-logo-day' })
    year_tag = content_tag(:div, year, { :class => 'event-logo-year' })

    content_tag(:div, day_tag + hour_tag + year_tag, options)
  end

  def formatted_date_in_time_zone(event, date, time_zone)
    "#{event.get_formatted_date(date.in_time_zone(time_zone), false)} (#{time_zone})"
  end

  def event_logo_link(event, options={})
    href = event_path(event)
    content_tag(:a, event_logo(event, options), { :href => href })
  end

  def button_url type
    case type
      when 'Google Plus' then googleplus_button_url
      when 'Twitter' then twitter_button_url
      when 'Facebook' then facebook_button_url
      when 'Linkedin' then linkedin_button_url
    end
  end

  def linkedin_button_url
    title = CGI.escape(@event.name)
    summary = CGI.escape(@event.summary)
    url = CGI.escape(request.original_url)
    "http://www.linkedin.com/shareArticle?mini=true&url=#{url}&summary=#{summary}&title=#{title}&source=Mconf Events"
  end

  def googleplus_button_url
    "https://plus.google.com/share?url=#{CGI.escape(request.original_url)}"
  end

  def twitter_button_url
    url = request.original_url
    text = "#{@event.summary}".truncate(140 - url.size) + " #{url}"
   "https://twitter.com/intent/tweet?text=#{CGI.escape(text)}"
  end

  def facebook_button_url
    url = CGI.escape(request.original_url)
    text = I18n.t('events.social_media.facebook_link', :url => url)
    "https://www.facebook.com/sharer/sharer.php?u=#{url}&t=#{text}"
  end

end
