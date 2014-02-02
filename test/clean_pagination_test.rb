require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  setup do
    @controller.stubs(:total_items).returns 101
    @controller.stubs(:max_range).returns 100
  end

  test 'naive request is OK if data not too large' do
    @controller.stubs(:total_items).returns 100

    @controller.expects(:action).with(100, 0)
    get :index
    assert_equal 200, response.status
    assert_equal 'items', response.headers['Accept-Ranges']
  end

  test 'naive request fails if data too large' do
    @controller.expects(:action).never
    get :index
    assert_equal 416, response.status
    assert_equal 'items', response.headers['Accept-Ranges']
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

  test 'an oversized range fails' do
    @request.headers['Range-Unit'] = 'items'
    @request.headers['Range'] = "0-100"

    @controller.expects(:action).never
    get :index
    assert_equal 416, response.status
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
end
