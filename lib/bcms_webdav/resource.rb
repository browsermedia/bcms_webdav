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

      def have_section
        @section != nil
      end

      def have_page
        @page != nil
      end

      def have_file
        @file != nil
      end

      # This will always be called by DAV4Rack controller before any other method
      def exist?
        path_to_find = Resource.normalize_path(path)
        @section = Section.with_path(path_to_find).first

        if have_section
          log "Have a section with path '#{path_to_find}'"
          @resource = @section if have_section
#          return self
        end

        @page = Page.with_path(path_to_find).first
        if have_page
          log "Have page w/ path '#{path_to_find}'."
          @resource = @page
#          return self
        end

        @file = Attachment.find_by_file_path(path)
        if have_file
          log "Found file w/ path '#{path_to_find}'."
          @resource = @file
        end

        return have_section || have_page || have_file
      end

      def children
        if exist?
          child_nodes = @section.child_nodes
          child_resources = []
          child_nodes.each do |node|
            child_resources << child_node(node)
          end
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
        have_file ? @resource.file_size : 0
      end

      def get(request, response)
        log "GET request for #{request.path}"
        if have_file
          file_location = @resource.full_file_location
          log "For attachment '#{@resource}' file location is '#{file_location}"
          file = Bcms::WebDAV::File.new(file_location)
          log "Sending file '#{file.path}'"
          response.body = file
        end
      end

      # Handle uploading file.
      def put(request, response)

        temp_file = request.body
        add_rails_like_methods(temp_file)

        section = find_section_for(path)

        file_block = FileBlock.new(:name=>path, :attachment_file=>request.body, :attachment_section => section, :attachment_file_path=>path, :publish_on_save=>true)
        unless file_block.save
          log "Couldn't save file."
          file_block.errors.each do |error|
            log error
          end
          return
        end
        log OK.class
        OK
      end

      def find_section_for(path)
        log "Looking up section for path '#{path}"
        path_obj = Path.new(path)
        section_path = path_obj.path_without_filename
        path_to_find = Resource.normalize_path(section_path)

        log "Section.path = #{path_to_find}"
        Section.with_path(path_to_find).first
      end

      private

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
        child_node = self.class.new(section_node.node.path, section_node.node.path, request, response, options.merge(:user => @user))
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

