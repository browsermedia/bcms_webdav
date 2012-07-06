require 'browsercms'
require 'dav4rack'

module BcmsWebdav
  class Engine < ::Rails::Engine
    isolate_namespace BcmsWebdav
    include Cms::Module

    config.to_prepare do
      require 'bcms_webdav/bcms_attachment_extensions'
      Cms::Attachment.send(:include, BcmsWebdav::Extensions::Attachments)
      Cms::Page.send(:include, BcmsWebdav::Extensions::Pages)
      Cms::Section.send(:include, BcmsWebdav::Extensions::Sections)
    end
  end
end
