module Bcms
  module WebDAV

    # A virtual resource representing a CMS
    #   * Section
    #   * File
    #   * Image
    class Resource < DAV4Rack::Resource

      def initialize(public_path, path, request, response, options)
        super(public_path, path, request, response, options)

        path_to_find = Resource.normalize_path(path)
        @section = Section.with_path(path_to_find).first
        log "Checking to see if section with path '#{path_to_find}'"

        if have_section
          @resource = @section if have_section
          return self
        end

        @page = Page.with_path(path_to_find).first
        log "Have page w/ path '#{path_to_find}'."
        if have_page
          @resource = @page
          return self
        end

        @file = Attachment.find_by_file_path(path)
        log "Found file w/ path '#{path_to_find}'."
        if have_file
          @resource = @file
          return self
        end
      end


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

      def exist?
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
        log "request for #{request.path}"
      end

      private

      def child_node(section_node)
        self.class.new(section_node.node.path, section_node.node.path, request, response, options.merge(:user => @user))
      end

      def self.log(m)
        Rails.logger.warn m
      end

      def log(m)
        Rails.logger.warn m
      end
    end

  end
end