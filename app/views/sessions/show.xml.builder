xml.instruct!
xml.session do |session|
  if authenticated?
    session.id(current_agent.id)
    session.login(current_agent.login)
  end

  if controller.session[:locale]
    session.locale(controller.session[:locale].to_s)
  end
end
