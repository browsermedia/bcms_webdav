module Cms::Routes
  def routes_for_bcms_webdav
    namespace(:cms) do |cms|
      #cms.content_blocks :webdavs
    end  
  end
end
