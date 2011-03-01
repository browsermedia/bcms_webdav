require 'dav4rack'
require 'dav4rack/file_resource'

module Bcms
  class WebDavMiddleware

    def initialize(app, options={})
      @app = app
      @dav4rack = DAV4Rack::Handler.new(:root => Rails.root.to_s, :root_uri_path => '/', :log_to => [STDERR, Logger::DEBUG], :resource_class=>Bcms::WebDAV::Resource)
      @options = options

      unless @options[:subdomain]
        @options[:subdomain] = 'webdav'
      end
    end

    def call(env)
      request = Rack::Request.new(env)
      if is_webdav?(request)
        return @dav4rack.call(env)
      else
        @app.call(env)
      end
    end

    private

    # A request is WebDAV if it matches either the port or subdomain (exactly).
    def is_webdav?(request)
      return true if @options[:on_port] && request.port == @options[:on_port]
      return true if request.host.starts_with?("#{@options[:subdomain]}.")
      false
    end


    def log(message)
      Rails.logger.warn message
    end
  end
end