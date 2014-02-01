require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  setup do
    @controller.stubs(:total_items).returns(1000)
  end

  test "should get normal response" do
    get :index

    assert_equal 200, response.status
  end

  test "should get response with pagination headers" do
    @request.headers['Range-Unit'] = 'items'
    @request.headers['Range'] = "0-99"

    get :index, {}, {'Range-Unit' => 'items', 'Range' => '0-99' }

    assert_equal 206, response.status
    assert_equal 'items', response.headers['Range-Unit']
    assert_equal '0-99/1000', response.headers['Content-Range']
  end
end
