# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
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
  def format_date(date)
    I18n.l(date, format: :short)
  end
end
