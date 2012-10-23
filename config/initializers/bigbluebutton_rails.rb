# Monkey-patches to add support for guest users in bigbluebutton_rails.
# TODO: This is not standard in BBB yet, so this should be temporary and might
#       be moved to bigbluebutton_rails in the future.

BigbluebuttonRoom.instance_eval do
  @guest_support = true
  class << self; attr_reader :guest_support; end
end

BigbluebuttonRoom.class_eval do
  # Copy of the default Bigbluebutton#join_url with support to :guest
  def join_url(username, role, password=nil)
    require_server

    case role
    when :moderator
      self.server.api.join_meeting_url(self.meetingid, username, self.moderator_password)
    when :attendee
      self.server.api.join_meeting_url(self.meetingid, username, self.attendee_password)
    when :guest
      params = { :isGuest => true }
      self.server.api.join_meeting_url(self.meetingid, username, self.attendee_password, params)
    else
      self.server.api.join_meeting_url(self.meetingid, username, password)
    end
  end
end
