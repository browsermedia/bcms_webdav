module MockFile
  FILES_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures'))
  def file_upload_object(options)
    file = Rack::Test::UploadedFile.new("#{FILES_DIR}/#{options[:original_filename]}", options[:content_type])
    # open(file.path, 'w'){|f| f << options[:read]}
    # file.original_path = options[:original_filename]
    # file.content_type = options[:content_type]
    file
  end
end
ActiveSupport::TestCase.send(:include, MockFile)