require "test_helper"
require 'mocha'

class WebDavSectionResourceTest < ActiveSupport::TestCase

  def setup
    @request = stub()
    @request.expects(:ip).returns('').at_least_once
    @about_us = Section.create!(:name=>"About Us", :path=>"/about-us", :parent=>Section.root.first)
    @resource = resource_for("/about-us")
    @resource.exist?
  end

  def teardown

  end

  test "convert webdav paths to cms paths" do
    assert_equal "/", Bcms::WebDAV::Resource.normalize_path("/")
    assert_equal "/", Bcms::WebDAV::Resource.normalize_path("")
    assert_equal "/about-us", Bcms::WebDAV::Resource.normalize_path("/about-us/"), "Remove trailing slashes, which CMS paths don't have"
    assert_equal "/about-us", Bcms::WebDAV::Resource.normalize_path("about-us/"), "Add starting slashes, which all CMS paths do have."
  end

  test "root path exists" do
    root_section = Section.create!(:name=>"My Site", :path=>"/", :root=>true)

    assert_not_nil Section.root.first, "Ensure the root section exists in the database"
    assert_equal true, resource_for("/").exist?
    assert_equal true, resource_for("").exist?, "WebDAV treats paths of '/' and '' as the root"

  end

  test "find subsection" do
    contact_us = Section.create!(:name=>"Contact us", :path=>"/about-us/contact-us", :parent=>@about_us)
    cu = resource_for("/about-us/contact-us")
    assert_equal true, cu.exist?
  end

  test "find section with no leading slash" do
    assert_equal true, resource_for("about-us/").exist?, "WebDAV seems to request subpaths (to collections) with no leading slash, plus a trailing slash"
  end

  test "exist?" do
    resource = resource_for("/about-us")
    assert_equal true, resource.exist?
  end

  test "exist? fails if section is missing" do
    resource = resource_for("/not-about-us")
    assert_equal false, resource.exist?
  end

  test "children returns all sections and pages" do
    child_section = Section.create!(:name=>"Child 1", :path=>"/about-us/child1", :parent=>@about_us)
    child_page = Page.create!(:name=>"Child 2", :path=>"/about-us/child2", :section=>@about_us)
    resource = resource_for("/about-us")
    children = resource.children
    assert_equal 2, children.size
    assert_equal "/about-us/child1", children[0].public_path
    assert_equal "/about-us/child2", children[1].public_path
  end


  test "propfind ensures all resources are initialized when getting properties" do
    child_section = Section.create!(:name=>"Child 1", :path=>"/about-us/child1", :parent=>@about_us)
    child_page = Page.create!(:name=>"Child 2", :path=>"/about-us/child2", :section=>@about_us)
    resource = resource_for("/about-us")
    children = resource.children

    assert_about_same_time child_section.created_at, children[0].creation_date
    assert_about_same_time child_page.created_at, children[1].creation_date
  end

  def assert_about_same_time(expected, actual)
    assert expected - actual <= 100, "Ensure the times are close"
  end
  test "creation_date" do
    resource = resource_for("/about-us")
    resource.exist?
    assert @about_us.created_at - resource.creation_date <= 100, "Ensure the times are close"
  end

  test "last_modified" do
    resource = resource_for("/about-us")
    assert @about_us.updated_at - resource.last_modified <= 100, "Ensure the times are close"
  end


  test "etag is implemented in some vaguely terrible way" do

    # Note: There is no particular logic to this etag, just trying to make it unique
    assert_not_nil @resource.etag
  end

  test "sections are collections" do
    assert(@resource.collection?)
  end

  test "sections are text/html" do
    assert_equal "text/html", @resource.content_type
  end

  test "sections have 0 content_length" do
    assert_equal 0, @resource.content_length
  end


  private

  def resource_for(path)
    Bcms::WebDAV::Resource.new(path, path, @request, Rack::MockResponse.new(200, {}, []), {})
  end


end

class PageResourceTest < ActiveSupport::TestCase
  def setup
    @request = stub()
    @request.expects(:ip).returns('').at_least_once
    @about_us = Section.create!(:name=>"About Us", :path=>"/about-us", :parent=>Section.root.first)
    @contact_us = Page.create!(:name=>"Contact Us", :path=>"/about-us/contact_us", :section=>@about_us)
    @resource = resource_for("/about-us/contact_us")
    @resource.exist?

  end

  test "exists" do
    assert_equal true, @resource.exist?
  end

  test "creation_date" do
    assert @contact_us.created_at - @resource.creation_date <= 100, "Ensure the times are close"
  end

  test "last_modified" do
    assert @contact_us.updated_at - @resource.last_modified <= 100, "Ensure the times are close"
  end

  test "pages are not collections" do
    assert_equal false, @resource.collection?
  end


  private
  def resource_for(path)
    Bcms::WebDAV::Resource.new(path, path, @request, Rack::MockResponse.new(200, {}, []), {})
  end
end

class FileResourceTest < ActiveSupport::TestCase
  def setup
    @request = stub()
    @request.expects(:ip).returns('').at_least_once

    @response = Rack::MockResponse.new(200, {}, [])
    @about_us = Section.create!(:name=>"About Us", :path=>"/about-us", :parent=>Section.root.first)

    @file = file_upload_object(:original_filename => "test.jpg",
                               :content_type => "image/jpeg", :rewind => true,
                               :size => "99", :read => "01010010101010101")
    @file_block = FileBlock.create!(:name=>"Testing", :attachment_file => @file, :attachment_section => @about_us, :attachment_file_path => "/about-us/test.jpg", :publish_on_save => true)

    @resource = resource_for("/about-us/test.jpg")
    @resource.exist?

  end

  test "exists" do
    assert_equal true, @resource.exist?
  end

  test "creation_date" do
    assert @file_block.created_at - @resource.creation_date <= 100, "Ensure the times are close"
  end

  test "last_modified" do
    assert @file_block.updated_at - @resource.last_modified <= 100, "Ensure the times are close"
  end

  test "pages are not collections" do
    assert_equal false, @resource.collection?
  end

  test "file size is correct" do
    assert_equal @file.size, @resource.content_length
  end

  test "content_type matches underlying file type" do
    assert_equal @file.content_type, @resource.content_type
  end

  test "Getting a file" do
    mock_rack_file = mock()
    mock_rack_file.expects(:path).returns("").at_least_once
    Bcms::WebDAV::File.expects(:new).with(@file_block.attachment.full_file_location).returns(mock_rack_file)

    @request.expects(:path).returns("/about-us/test.jpg").at_least_once
    @response.expects(:body=).with(mock_rack_file)

    @resource.get(@request, @response)

  end

  test "Finding a section includes child files as resources" do
    @section = resource_for("/about-us")
    assert_equal 1, @section.children.size
    assert_equal "/about-us/test.jpg", @section.children.first.path
  end


  test "determine target_section" do
    path = Bcms::WebDAV::Path.new('/about-us/test.jpg')
    assert_equal "test.jpg", path.file_name
    assert_equal '/about-us/', path.path_without_filename

    assert_equal @about_us, @resource.find_section_for("/about-us/test.jpg")
  end

  test "Uploading files with spaces or special characters" do
    path = Bcms::WebDAV::Path.new('/about-us/test with spaces.jpg')
    assert_equal "test_with_spaces.jpg", path.file_name
    assert_equal '/about-us/', path.path_without_filename

    assert_equal @about_us, @resource.find_section_for("/about-us/test with spaces.jpg")
  end
  test "Uploading files with encoded spaces" do
    path = Bcms::WebDAV::Path.new('/about-us/test%20with%20spaces.jpg')
    assert_equal "test_with_spaces.jpg", path.file_name
    assert_equal '/about-us/', path.path_without_filename

    assert_equal @about_us, @resource.find_section_for("/about-us/test with spaces.jpg")
  end

  test "uploading files to root section" do
    assert_equal Section.root.first, @resource.find_section_for("/test.jpg")
  end

  test "parse empty section" do
    path = Bcms::WebDAV::Path.new('/test.jpg')
    assert_equal "test.jpg", path.file_name


  end

  test "parse missing slash section" do
    path = Bcms::WebDAV::Path.new('test.jpg')
    assert_equal "test.jpg", path.file_name


  end
  private
  def resource_for(path)
    Bcms::WebDAV::Resource.new(path, path, @request, @response, {})
  end
end


