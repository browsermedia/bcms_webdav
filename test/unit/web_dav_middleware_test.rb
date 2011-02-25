require "test_helper"
require 'mocha'

class WebDavMiddlewareTest < ActiveSupport::TestCase


  def setup
    @webdav = Bcms::WebDavMiddleware.new(nil)
    @request = mock()
    @path = '/public'
  end

  def teardown

  end

  test "is_webdav" do
    @request.expects(:path).returns("#{@path}/anything")
    assert_equal true, @webdav.send(:is_webdav?, @request)

    @request.expects(:path).returns("#{@path}/")
    assert_equal true, @webdav.send(:is_webdav?, @request)

    @request.expects(:path).returns("#{@path}")
    assert_equal true, @webdav.send(:is_webdav?, @request)
  end

  test "not is_webdav" do
    @request.expects(:path).returns("/not#{@path}")
    assert_equal false, @webdav.send(:is_webdav?, @request)

    @request.expects(:path).returns("/not/#{@path}")
    assert_equal false, @webdav.send(:is_webdav?, @request)

    @request.expects(:path).returns("/")
    assert_equal false, @webdav.send(:is_webdav?, @request)
  end

  test "Setting up to use a port for detection for webdav requests" do
    webdav = Bcms::WebDavMiddleware.new(nil, {:on_port=>3000})
    @request.expects(:port).returns(3000)
    assert_equal true, webdav.is_webdav?(@request)
  end
end