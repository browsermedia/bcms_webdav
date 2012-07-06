module Bcms
  module WebDAV

    # Inherits from Rack File in order to change where paths are looked up from, since the
    # public path of CMS files is different that actual file path.
    class File < Rack::File

      # @param [String] absolute_file_path Absolute path to the file on the server.
      def initialize(absolute_file_path)
        @cms_path_to_file = absolute_file_path
        
        # Normally, files are restricted under the root of the web application.
        # Here, we set the root to blank. The cms_path_to_file is the complete path to the file.
        @root = ""
      end

      # As of Rack 1.4.1, we override this call to have it stuff the CMS path into the PATH_INFO
      def call(env)
        env['PATH_INFO'] = @cms_path_to_file
        dup._call(env)
      end

    end
  end
end