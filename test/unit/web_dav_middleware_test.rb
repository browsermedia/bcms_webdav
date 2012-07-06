require "test_helper"

class WebDavMiddlewareTest < ActiveSupport::TestCase


  def setup
    @webdav = Bcms::WebDavMiddleware.new(nil)
    @request = mock()
    @path = '/public'
  end

  def teardown

  end

  test "subdomain is_webdav too" do
    @request.expects(:host).returns("webdav.example.com")
    assert_equal true, @webdav.send(:is_webdav?, @request)

    @request.expects(:host).returns("webdav.localhost")
    assert_equal true, @webdav.send(:is_webdav?, @request)

  end

  test "non-subdomain is_webdav too" do
    @request.expects(:host).returns("localhost")
    assert_equal false, @webdav.send(:is_webdav?, @request)

    @request.expects(:host).returns("www.webdav.example.com")
    assert_equal false, @webdav.send(:is_webdav?, @request)

  end

  test "can configure different subdomain for webdav" do
    webdav = Bcms::WebDavMiddleware.new(nil, {:subdomain=>"dav"})

    @request.expects(:host).returns("dav.example.com")
    assert_equal true, webdav.send(:is_webdav?, @request)

    @request.expects(:host).returns("webdav.example.com")
    assert_equal false, webdav.send(:is_webdav?, @request)
  end

  test "Setting up to use a port for detection for webdav requests" do
    webdav = Bcms::WebDavMiddleware.new(nil, {:port=>3000})
    @request.expects(:port).returns(3000)
    assert_equal true, webdav.send(:is_webdav?, @request)
  end
end