module Bcms
  module WebDAV

    # Inherits from Rack File in order to change where paths are looked up from, since the
    # public path of CMS files is different that actual file path.
    class File < Rack::File

      # This should be an absolute file path
      def initialize(absolute_file_path)
        @path = absolute_file_path
      end

      # Don't look up from PATH, look up from passed in variable
      def _call(env)
        Rails.logger.debug "Starting to serve file @ path #{@path}"

        # From here down is a copy&paste of Rack::File#_call
        begin
          if F.file?(@path) && F.readable?(@path)
            serving
          else
            raise Errno::EPERM
          end
        rescue SystemCallError
          not_found
        end
      end
    end
  end
end