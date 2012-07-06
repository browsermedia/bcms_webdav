# Exist to ensure compliance with Resource API for WebDAV (like Section and Pages).
module BcmsWebdav
  
  # Attachment#path is actually the file path, so we have to define a new method that all
  # child_nodes can use.
  module Extensions
    module Attachments
      def relative_path
        url
      end
    end
    
    module Pages
      def relative_path
        path
      end
    end
    
    module Sections
      def relative_path
        path
      end
    end
    
  end
end
