require 'test_helper'

def parse_link_ranges header
  links = Hash.new
  (header || '').split(',').each do |link|
    link =~ /rel="(.*)".*items="(.*)"/
    links[$1] = $2
  end
  links
end

class ApplicationControllerTest < ActionController::TestCase
  setup do
    @controller.stubs(:total_items).returns 101
    @controller.stubs(:max_range).returns 100
  end

  test 'rangeless request range works normally if max_range >= total' do
    @controller.stubs(:total_items).returns 100

    @controller.expects(:action).with(100, 0)
    get :index
    assert_equal 200, response.status
    assert_equal 'items', response.headers['Accept-Ranges']
  end

  test 'rangeless request truncates if max_range < total' do
    @controller.expects(:action).with(100, 0)
    get :index
    assert_equal 206, response.status
    assert_equal 'items', response.headers['Accept-Ranges']
    assert_equal '0-99/101', response.headers['Content-Range']
  end

  test 'an acceptable range succeeds' do
    @request.headers['Range-Unit'] = 'items'
    @request.headers['Range'] = "0-99"

    @controller.expects(:action).with(100, 0)
    get :index
    assert_equal 206, response.status
    assert_equal 'items', response.headers['Range-Unit']
    assert_equal '0-99/101', response.headers['Content-Range']
  end

  test 'an oversized range is truncated' do
    @request.headers['Range-Unit'] = 'items'
    @request.headers['Range'] = "0-100"

    get :index
    assert_equal 206, response.status
    assert_equal 'items', response.headers['Range-Unit']
    assert_equal '0-99/101', response.headers['Content-Range']
  end

  test "passes along exceptional status codes" do
    @request.headers['Range-Unit'] = 'items'
    @request.headers['Range'] = "0-99"

    [100, 301, 404, 500].each do |code|
      @controller.stubs(:index_status).returns code
      get :index
      assert_equal code, response.status
    end
  end

  test "reports infinite/unknown collection" do
    @controller.stubs(:total_items).returns Float::INFINITY

    @request.headers['Range-Unit'] = 'items'
    @request.headers['Range'] = "0-9"
    get :index
    assert_equal '0-9/*', response.headers['Content-Range']
  end

  test "refuses offside ranges" do
    @request.headers['Range-Unit'] = 'items'
    @request.headers['Range'] = "1-0"

    @controller.expects(:action).never
    get :index
    assert_equal 416, response.status
    assert_equal '*/101', response.headers['Content-Range']
  end

  test "handles ranges beyond collection length via truncation" do
    @request.headers['Range-Unit'] = 'items'
    @request.headers['Range'] = "50-200"

    @controller.expects(:action).with(51, 50)
    get :index

    assert_equal 206, response.status
    assert_equal '50-100/101', response.headers['Content-Range']
  end

  test "includes link headers" do
    @controller.stubs(:total_items).returns 100

    @request.headers['Range-Unit'] = 'items'
    @request.headers['Range'] = "20-29"

    get :index
    links = parse_link_ranges response.headers['Link']

    assert_equal '30-39', links['next']
    assert_equal '10-19', links['prev']
    assert_equal '0-9', links['first']
    assert_equal '90-99', links['last']
  end

  test "next page range can extend beyond last item" do
    @controller.stubs(:total_items).returns 100

    @request.headers['Range-Unit'] = 'items'
    @request.headers['Range'] = "50-89"

    get :index
    links = parse_link_ranges response.headers['Link']

    assert_equal '90-129', links['next']
  end

  test "previous page range cannot go negative" do
    @controller.stubs(:total_items).returns 100

    @request.headers['Range-Unit'] = 'items'
    @request.headers['Range'] = "10-99"

    get :index
    links = parse_link_ranges response.headers['Link']

    assert_equal '0-89', links['prev']
  end

  test "first page range always starts at zero" do
    @controller.stubs(:total_items).returns 100

    @request.headers['Range-Unit'] = 'items'
    @request.headers['Range'] = "63-72"

    get :index
    links = parse_link_ranges response.headers['Link']

    assert_equal '0-9', links['first']
  end

  test "last page range can extend beyond the last item" do
    @controller.stubs(:total_items).returns 100

    @request.headers['Range-Unit'] = 'items'
    @request.headers['Range'] = "0-6"

    get :index
    links = parse_link_ranges response.headers['Link']

    assert_equal '98-104', links['last']
  end

  test "shifts penultimate page to beginning, preserving length" do
    @controller.stubs(:total_items).returns 100

    @request.headers['Range-Unit'] = 'items'
    @request.headers['Range'] = "10-49"

    get :index
    links = parse_link_ranges response.headers['Link']

    assert_equal '0-39', links['prev']
    assert_equal '0-39', links['first']
  end
end
