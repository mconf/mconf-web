module CapybaraContentMatchers

  def have_notification(text)
    have_selector("#notification-flashs", :text => text)
  end

end
