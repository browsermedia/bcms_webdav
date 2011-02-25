require 'dav4rack'
require 'dav4rack/file_resource'

module Bcms
  class WebDavMiddleware

    def initialize(app, options={})
      @app = app
      @dav4rack = DAV4Rack::Handler.new(:root => Rails.root.to_s, :root_uri_path => '/', :log_to => [STDERR, Logger::DEBUG], :resource_class=>Bcms::WebDAV::Resource)
      @options = options
    end

    def call(env)
      request = Rack::Request.new(env)
      if is_webdav?(request)
#        log "WebDAV Request: For path '#{request.path}'"
        return @dav4rack.call(env)
      else
#        log("Not a WebDAV request '#{request.path}'")
        @app.call(env)
      end
    end

    def is_webdav?(request)
      return true if @options[:on_port] && request.port == @options[:on_port]
      path = request.path
      return path == "/public" || path.starts_with?("/public/")
    end

    def log(message)
      Rails.logger.warn message
    end
  end
end