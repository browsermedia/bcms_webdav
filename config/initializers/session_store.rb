# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_bcms_webdav_session',
  :secret      => '3fd13b18e0cc1eb4e388e28c1b51ea14a612e2421229b56892b97abf25ae6c58f4df4725d2d1af1b8dcc48dffc566fe365cb3255574aa6a86d3abf6f8a26fa98'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
