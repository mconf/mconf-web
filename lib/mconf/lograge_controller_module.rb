module Mconf::LogrageControllerModule

  # The payload is used by lograge. We add more information to it here so that it is saved
  # in the log.
  def append_info_to_payload(payload)
    super

    payload[:session] = {
      id: session.id,
      ldap_session: !session[Mconf::LDAP::SESSION_KEY].blank?,
      shib_session: !session[Mconf::Shibboleth::SESSION_KEY].blank?
    } unless session.nil?
    payload[:current_user] = {
      id: current_user.id,
      email: current_user.email,
      username: current_user.username,
      name: current_user.full_name,
      superuser: current_user.superuser?,
      can_record: current_user.can_record?
    } unless current_user.nil?
    if payload[:controller] == "CustomBigbluebuttonRoomsController" && payload[:action] == "join"
      payload[:room] = {
        meetingid: @room.meetingid,
        name: @room.name,
        member: !current_user.nil?,
        user: {
          name: current_user.try(:full_name) || (params[:user].present? ? params[:user][:name] : nil)
        }
      } unless @room.nil?
    end
  end

end
