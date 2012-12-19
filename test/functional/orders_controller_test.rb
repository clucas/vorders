require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  setup do
    @order = FactoryGirl.create(:order)
    @order2 = FactoryGirl.create(:order)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:orders)
  
    get :index, :format => :json
    assert_response :success
    assert_not_nil assigns(:orders)
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "should create order" do
    assert_difference('Order.count') do
      post :create, order: { name: @order.name, order_on: @order.order_on }
    end
  
    assert_redirected_to order_path(assigns(:order))
  
    assert_difference('Order.count') do
      post :create, order: { name: @order.name, order_on: @order.order_on }, :format => :json
    end
  
    assert_response 201
  end
  
  test "should show order" do
    get :show, id: @order
    assert_response :success
  
    get :show, id: @order, :format => :json
    assert_response :success
  end
  
  test "should get edit" do
    get :edit, id: @order
    assert_response :success
  end
  
  test "should update order" do
    put :update, id: @order, order: { name: "different order name", order_on: Date.today + 1.day}
    assert_redirected_to order_path(assigns(:order))
  
    put :update, id: @order, order: { name: "different order name again", order_on: Date.today + 1.day}, :format => :json
    assert_response 204
  end
  
  test "should destroy order" do
    assert_raise(ActionController::RoutingError) {delete :destroy, id: @order}
    # assert_redirected_to orders_path
  
    assert_raise(ActionController::RoutingError) {delete :destroy, id: @order, :format => :json}
    # assert_redirected_to orders_path
  end
  
  
  # clearly not the most efficient tests but they do the job for tonight and it is also only testing the happy path
  test "should not cancel a draft order without a reason" do
    order = FactoryGirl.create(:order)
    product = FactoryGirl.create(:product)
    item = FactoryGirl.create(:item, :product => product, :order => order )
    put :update, id: order.id, order: { order_action: "cancel"}
    assert_redirected_to order_path(assigns(:order))
    order.reload
    assert order.draft?

    order2 = FactoryGirl.create(:order)
    product = FactoryGirl.create(:product)
    item = FactoryGirl.create(:item, :product => product, :order => order2 )
    put :update, id: order2.id, order: { order_action: "cancel"}, :format => :json
    assert_response 204
    order2.reload
    assert order2.draft?
  end

  test "should cancel a draft order with a reason" do
    order = FactoryGirl.create(:order)
    product = FactoryGirl.create(:product)
    item = FactoryGirl.create(:item, :product => product, :order => order )
    put :update, id: order.id, order: { order_action: "cancel", :reason => "reason"}
    assert_redirected_to order_path(assigns(:order))
    order.reload
    assert order.cancelled?

    order2 = FactoryGirl.create(:order)
    product = FactoryGirl.create(:product)
    item = FactoryGirl.create(:item, :product => product, :order => order2 )
    put :update, id: order2.id, order: { order_action: "cancel", :reason => "reason"}, :format => :json
    assert_response 204
    order2.reload
    assert order2.cancelled?
  end

  test "should not place an order without a line item" do
    order = FactoryGirl.create(:order)
    put :update, id: order.id, order: { order_action: "place"}
    assert_redirected_to order_path(assigns(:order))
    order.reload
    assert order.draft?

    order2 = FactoryGirl.create(:order)
    put :update, id: order2.id, order: { order_action: "place"}, :format => :json
    assert_response 204
    order2.reload
    assert order2.draft?
  end

  test "should place an order" do
    order = FactoryGirl.create(:order)
    product = FactoryGirl.create(:product)
    item = FactoryGirl.create(:item, :product => product, :order => order )
    put :update, id: order.id, order: { order_action: "place"}
    assert_redirected_to order_path(assigns(:order))
    order.reload
    assert order.placed?

    order2 = FactoryGirl.create(:order)
    product = FactoryGirl.create(:product)
    item = FactoryGirl.create(:item, :product => product, :order => order2 )
    put :update, id: order2.id, order: { order_action: "place"}, :format => :json
    assert_response 204
    order2.reload
    assert order2.placed?
  end

  test "should pay an order" do
    order = FactoryGirl.create(:order)
    product = FactoryGirl.create(:product)
    item = FactoryGirl.create(:item, :product => product, :order => order )
    put :update, id: order.id, order: { order_action: "place"}
    assert_redirected_to order_path(assigns(:order))
    order.reload
    assert order.placed?
    put :update, id: order.id, order: { order_action: "pay"}
    assert_redirected_to order_path(assigns(:order))
    order.reload
    assert order.paid?

    order2 = FactoryGirl.create(:order)
    product = FactoryGirl.create(:product)
    item = FactoryGirl.create(:item, :product => product, :order => order2 )
    put :update, id: order2.id, order: { order_action: "place"}, :format => :json
    assert_response 204
    order2.reload
    assert order2.placed?
    put :update, id: order2.id, order: { order_action: "pay"}, :format => :json
    assert_response 204
    order2.reload
    assert order2.paid?
  end
  
  test "should cancel a placed order with a reason" do
    order = FactoryGirl.create(:order)
    product = FactoryGirl.create(:product)
    item = FactoryGirl.create(:item, :product => product, :order => order )
    put :update, id: order.id, order: { order_action: "place"}
    assert_redirected_to order_path(assigns(:order))
    order.reload
    assert order.placed?
    put :update, id: order.id, order: { order_action: "cancel", :reason => "reason"}
    assert_redirected_to order_path(assigns(:order))
    order.reload
    assert order.cancelled?

    order2 = FactoryGirl.create(:order)
    product = FactoryGirl.create(:product)
    item = FactoryGirl.create(:item, :product => product, :order => order2 )
    put :update, id: order2.id, order: { order_action: "place"}, :format => :json
    assert_response 204
    order2.reload
    assert order2.placed?
    put :update, id: order2.id, order: { order_action: "cancel", :reason => "reason"}, :format => :json
    assert_response 204
    order2.reload
    assert order2.cancelled?
  end
  
  test "should not cancel a placed order without a reason" do
    order = FactoryGirl.create(:order)
    product = FactoryGirl.create(:product)
    item = FactoryGirl.create(:item, :product => product, :order => order )
    put :update, id: order.id, order: { order_action: "place"}
    assert_redirected_to order_path(assigns(:order))
    order.reload
    assert order.placed?
    put :update, id: order.id, order: { order_action: "cancel"}
    assert_redirected_to order_path(assigns(:order))
    order.reload
    assert order.placed?

    order2 = FactoryGirl.create(:order)
    product = FactoryGirl.create(:product)
    item = FactoryGirl.create(:item, :product => product, :order => order2 )
    put :update, id: order2.id, order: { order_action: "place"}, :format => :json
    assert_response 204
    order2.reload
    assert order2.placed?
    put :update, id: order2.id, order: { order_action: "cancel"}, :format => :json
    assert_response 204
    order2.reload
    assert order2.placed?
  end
  
end
