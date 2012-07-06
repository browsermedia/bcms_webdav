module Bcms
  module WebDAV

    # A virtual resource representing a CMS
    #   * Section
    #   * File
    #   * Image
    class Resource < DAV4Rack::Resource

      include DAV4Rack::HTTPStatus

      # Converts WebDAV paths into CMS paths. Both have slightly different rules.
      def self.normalize_path(webdav_path)
        path = webdav_path
        if path.end_with?("/")
          path.gsub!(/\/$/, '')
        end
        unless path.start_with?("/")
          path = path.insert(0, "/")
        end
        path = "/" if path == ''
        path

      end


      def authenticate(username, password)
        log "Authenticating user '#{username}'"
        user = Cms::User.authenticate(username, password)

        unless user
          Rails.logger.error "Failed authentication attempt by user '#{username}'"
          return false
        end
        user.able_to?(:administrate)
      end

      def have_section
        @section != nil
      end

      def have_page
        @page != nil
      end

      def have_file
        @file != nil
      end



      # This should always be called by DAV4Rack controller before any other primary operation (get, put) on a resource.
      def exist?
        path_to_find = Resource.normalize_path(path)
        @section = Cms::Section.with_path(path_to_find).first

        if have_section
          log_exists('section', path_to_find)
          @resource = @section if have_section
        end

        @page = Cms::Page.with_path(path_to_find).first
        if have_page
          log_exists('page', path_to_find)
          @resource = @page
        end

        @file = Cms::Attachment.find_live_by_file_path(path)
        if have_file
          log_exists('file', path_to_find)
          @resource = @file
        end

        have_section || have_page || have_file
      end

      def children
        if exist?
          child_nodes = @section.child_nodes
          child_resources = []
          child_nodes.each do |node|
            child_resources << child_node(node)
          end
          child_resources.compact!
          return child_resources
        else
          []
        end
      end

      def creation_date
        @resource.created_at
      end

      def last_modified
        @resource.created_at if exist?
      end

      def collection?
        have_section ? true : false
      end

      def etag
        sprintf('%x-%x-%x', @resource.id, creation_date.to_i, last_modified.to_i) if exist?
      end

      def content_type
        have_file ? @resource.file_type : "text/html"
      end

      def content_length
        have_file ? @resource.size : 0
      end

      def get(request, response)
        log "GET request for #{request.path}"
        if have_file
          path_to_file = @resource.data.path
          log "For attachment '#{@resource}' path to file is '#{path_to_file}"
          file = Bcms::WebDAV::File.new(path_to_file)
          log "Sending file '#{file.path}'"
          response.body = file
        end
      end

      # Handle uploading file.
      def put(request, response)
        temp_file = extract_tempfile(request)

        add_rails_like_methods(temp_file)

        section = find_section_for(path)

        file_block = Cms::FileBlock.new(:name=>path, :attachment_file=>temp_file, :attachment_section => section, :attachment_file_path=>path, :publish_on_save=>true)
        unless file_block.save
          log "Couldn't save file."
          file_block.errors.each do |error|
            log error
          end
          return
        end
        OK
      end

      def find_section_for(path)
        log "Looking up section for path '#{path}"
        path_obj = Path.new(path)
        section_path = path_obj.path_without_filename
        path_to_find = Resource.normalize_path(section_path)

        log "Section.path = #{path_to_find}"
        Cms::Section.with_path(path_to_find).first
      end

      private

      # Different webservers have slightly different behavior for uploaded files.
      #   1. Webrick/mongrel - body is a TempFile
      #   2. Passenger - body is a PhusionPassenger::Utils::RewindableInput
      #
      # Until Rails 3, which may have a consistent middleware for extracting a Tempfile, we have to do it this way.
      def extract_tempfile(request)
        input = request.body
        if input
          # Handle Mongrel
          return input if input.is_a?(Tempfile)

          # Handle Passenger
          # This is highly brittle and terrible.
          if input.respond_to?(:make_rewindable, true)
            input.size # Force creation of Tempfile
            return input.instance_variable_get(:@rewindable_io)
          end
        end


      end

      def log_exists(type, path)
        log "Resource of type '#{type}' with path '#{path}' exists."
      end

      # Make this TempFile object act like a RailsTempFile
      def add_rails_like_methods(temp_file)
        # For the purposes of Rails 2, this will have to do. Rails 3 make this much easier by providing additional
        # Rack processors for ActionDispatch::Http::UploadedFile which makes this unncessary.

        def temp_file.content_type
          'application/octet-stream'
        end

        def temp_file.original_filename
          path
        end

        def temp_file.local_path
          self.path
        end
      end

      def child_node(section_node)
        node_object = section_node.node
        return nil if node_object == nil || node_object.is_a?(Cms::Link)
        child_node = self.class.new(node_object.relative_path, node_object.relative_path, request, response, options.merge(:user => @user))
        child_node.exist? # Force lookup of info from DB.
        child_node
      end

      def self.log(m)
        Rails.logger.warn m
      end

      def log(m)
        Rails.logger.warn m
      end
    end


    class Path
      include Cms::Behaviors::Attaching::InstanceMethods

      # Based on http://stackoverflow.com/questions/27745/getting-parts-of-a-url-regex
      # Tested in http://rubular.com/
      #
      # This will also convert paths with spaces, etc, into CMS style sanatized paths.
      def initialize(path_as_string)

        @string_path = sanitize_file_path(CGI::unescape(path_as_string))
        Rails.logger.warn "Sanitized path is: " + @string_path
        @regex = /^((http[s]?|ftp):\/)?\/?([^:\/\s]+)((\/\w+)*\/)([\w\-\.]+[^#?\s]+)(.*)?(#[\w\-]+)?$/
        scanned = @string_path.scan(@regex)
        @parts = scanned[0]
      end

      def sanitize_file_path(path)
        Cms::Attachment.sanitize_file_path(path)
      end
      
      def parts
        @parts
      end

      def file_name
        return @parts[5] if @parts # Most longer URLs

        # i.e. /somefilename.jpg
        if @parts == nil
          if @string_path.starts_with?("/") && @string_path.count("/") == 1
            return @string_path.gsub("/", '')
          end

          # i.e. somefilename.jpg
          return @string_path
        end
      end

      def path_without_filename
        @string_path.gsub(file_name, '')
      end

    end
  end
end

