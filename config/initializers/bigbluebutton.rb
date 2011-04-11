require 'bigbluebutton-api'

# TODO Temporary, until bigbluebutton_rails is fully functional
if BigbluebuttonServer.table_exists?
  server = BigbluebuttonServer.first
  BBB_API = BigBlueButton::BigBlueButtonApi.new(server.url, server.salt, server.version, RAILS_ENV != :production)
end
