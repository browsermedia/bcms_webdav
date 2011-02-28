require "test_helper"

class AttachmentTest < ActiveSupport::TestCase

  def setup

  end

  def teardown

  end

  test "Attachment should respond to 'path' just like pages and sections." do
    a = Attachment.new(:file_path=>"/test.jpg")
    assert_equal "/test.jpg", a.path
  end
end