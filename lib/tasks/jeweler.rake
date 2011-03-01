begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "bcms_webdav"
    gemspec.rubyforge_project = "browsercms"
    gemspec.summary = "A BrowserCMS module for WebDAV"
    gemspec.email = "github@browsermedia.com"
    gemspec.homepage = "https://github.com/browsermedia/bcms_webdav"
    gemspec.description = "Turns a BrowserCMS site into a WebDAV server, allowing access for bulk uploading files."
    gemspec.authors = ["BrowserMedia"]
    gemspec.files = []
    gemspec.files += Dir["app/**/*"]
    gemspec.files -= Dir["app/views/layouts/templates/*"]
    gemspec.files -= Dir["app/controllers/application_controller.rb"]
    gemspec.files -= Dir["app/helpers/application_helper.rb"]
    gemspec.files += Dir["doc/**/*"]
    gemspec.files += Dir["db/migrate/[0-9]*.rb"].reject {|f| f =~ /_browsercms|_load_seed/ }
    gemspec.files += Dir["lib/**/*"]
    gemspec.files -= Dir["lib/task/jeweler.rake"]
    gemspec.files += Dir["rails/init.rb"]
    gemspec.files += Dir["public/bcms/webdav/**/*"]
    gemspec.files += Dir["README.rdoc"]
    gemspec.files += Dir["Rakefile"]
    gemspec.files += Dir["LICENSE.txt"]
    gemspec.files += Dir["COPYRIGHT.txt"]
    gemspec.files += Dir["VERSION"]
    gemspec.add_dependency('browsercms', '>=3.1')
    gemspec.add_dependency('dav4rack', '>=0.2.1')
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

Jeweler::GemcutterTasks.new