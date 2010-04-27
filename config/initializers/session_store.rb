# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_vcc_session',
  :secret      => 'c11f3c6e1ae902099ec9ec43f0dd382e2b1b329d26cc21736c01809497ee36e31b61b76054b161891460e6109774f832c1a000f32ece8fcb6fbf1f334d2d3e13',
  :session_http_only => false
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
