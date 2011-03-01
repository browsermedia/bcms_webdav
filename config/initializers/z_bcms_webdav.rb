
# This requires two separate webrick instances, webdav on Port 3000 and the CMS on port 3001.
Rails.configuration.middleware.use Bcms::WebDavMiddleware, :on_port=>3000

# This works if you have modified your computer hosts file to include:
# 127.0.0.1 webdav.localhost
# Rails.configuration.middleware.use Bcms::WebDavMiddleware