# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bcms_webdav/version"

Gem::Specification.new do |s|
  s.name = %q{bcms_webdav}
  s.version = BcmsWebdav::VERSION

  s.authors = ["BrowserMedia"]
  s.description = %q{Turns a BrowserCMS site into a WebDAV server, allowing access for bulk uploading files.}
  s.email = %q{github@browsermedia.com}
  
  s.extra_rdoc_files = ["README.markdown"]

  s.files = Dir["{app,config,db,lib}/**/*"]
  s.files += Dir["Gemfile", "LICENSE.txt", "COPYRIGHT.txt", "GPL.txt" ]
  
  s.homepage = %q{https://github.com/browsermedia/bcms_webdav}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{browsercms}
  s.summary = %q{A BrowserCMS module for WebDAV}

  s.add_dependency("browsercms", "< 3.6.0", ">= 3.5.0")
  s.add_dependency("dav4rack", "~>0.2.1")
  
end

