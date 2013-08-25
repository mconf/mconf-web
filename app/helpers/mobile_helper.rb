require 'version'

module MobileHelper

  def mobile_google_play_link
    "https://play.google.com/store/apps/details?id=org.mconf.android.mconfmobile"
  end

  def mobile_google_play_image
    "https://developer.android.com/images/brand/#{I18n.locale}_generic_rgb_wo_45.png"
  end

  # Default link to open the popup to join a webconference using a mobile device as a button.
  # If url is nil, renders a disabled button
  def webconf_mobile_icon_link(url, options={})
    cls = 'btn'
    cls = options.has_key?(:class) ? cls + " " + options[:class] : cls
    webconf_mobile_link(url, :class => cls, :text => t('_other.webconference.join_mobile_short'))
  end

  # Default link to open the popup to join a webconference using a mobile device as a simple
  # link, not a button. If url is nil, renders a disabled button
  def webconf_mobile_link(url, options={})
    options[:text] ||= t('_other.webconference.join_mobile')

    cls = 'webconf-join-mobile-link'
    unless url
      url = '#'
      cls += ' disabled login-to-enable'
    end
    cls = options.has_key?(:class) ? cls + " " + options[:class] : cls

    link_to url, :class => cls  do
      content_tag :span, options[:text]
    end
  end

end
