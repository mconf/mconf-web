# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module DatesHelper

  # Renders a <span> with a simplified date and with a title with the full date.
  # The inside text is obtained with `time_ago_in_words`.
  def formatted_time_ago(date, options = {}, time_ago_options = {})
    base_classes = "thread-updated-at updated-at"
    options[:class] = options.key?(:class) ? "#{base_classes} #{options[:class]}" : base_classes
    options[:title] = I18n.l(date, format: :long)

    time_ago_options[:highest_measures] = 2 unless time_ago_options.key?(:highest_measures)
    time_ago_options[:vague] = true unless time_ago_options.key?(:vague)
    text = t('_other.updated_time_ago', time: time_ago_in_words(date, time_ago_options))

    content_tag :span, text, options
  end

  # Formats a date object to be shown in a view
  def format_date(date, format=:short, include_time=true)
    if date.present?
      if date.is_a?(Integer) && date.to_s.length == 13
        value = Time.at(date/1000)
      else
        value = Time.at(date)
      end
      if include_time
        I18n.l(value, format: format)
      else
        I18n.l(value.to_date, format: format)
      end
    else
      nil
    end
  end

  def format_time(date)
    if date.present?
      if date.is_a?(Integer) && date.to_s.length == 13
        value = Time.at(date/1000)
      else
        value = Time.at(date)
      end
      value.to_s(:time)
    else
      nil
    end
  end

  # Returns true if `date` is in the current year.
  def this_year?(date)
    if date.present?
      if date.is_a?(Integer) && date.to_s.length == 13
        Time.at(date/1000).year == Time.current.year
      else
        Time.at(date).year == Time.current.year
      end
    else
      false
    end
  end

  def timezone_abbreviation(tz)
    tz.tzinfo.current_period.abbreviation.to_s
  end

  def user_timezone_abbreviation(user)
    timezone_abbreviation(Mconf::Timezone.user_time_zone(user))
  end
end
