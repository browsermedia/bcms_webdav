require "test_helper"

class AttachmentTest < ActiveSupport::TestCase

  def setup

  end

  def teardown

  end

  test "Attachment should respond to 'relative_path'" do
    a = Cms::Attachment.new
    assert a.respond_to?(:relative_path)
  end
  
  test "Page should respond to 'relative_path'" do
    a = Cms::Page.new
    assert a.respond_to?(:relative_path)
  end
  
  test "Section should respond to 'relative_path'" do
    a = Cms::Section.new
    assert a.respond_to?(:relative_path)
  end
end