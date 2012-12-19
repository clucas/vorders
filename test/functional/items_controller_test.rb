require 'test_helper'

class ItemsControllerTest < ActionController::TestCase
  setup do
    @order = FactoryGirl.create(:order)
    @product = FactoryGirl.create(:product)
    @product2 = FactoryGirl.create(:product)
    @product3 = FactoryGirl.create(:product)
    @product4 = FactoryGirl.create(:product)
    @item = FactoryGirl.create(:item, :product => @product, :order => @order )
    @item2 = FactoryGirl.create(:item, :product => @product2, :order => @order )
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:items)

    get :index, :format => :json
    assert_response :success
    assert_not_nil assigns(:items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create item" do
    assert_raise(ActiveRecord::RecordNotUnique) {post :create, item: { :quantity => @item.quantity, :product_id => @product.id, :order_id => @order.id }}
    assert_difference('Item.count') do
      post :create, item: { :quantity => @item.quantity, :product_id => @product3.id, :order_id => @order.id }
    end

    assert_redirected_to item_path(assigns(:item))

    assert_raise(ActiveRecord::RecordNotUnique) {post :create, item: { :quantity => @item.quantity, :product_id => @product.id, :order_id => @order.id }, :format => :json}
    assert_difference('Item.count') do
      post :create, item: { :quantity => @item.quantity, :product_id => @product4.id, :order_id => @order.id }, :format => :json
    end

    assert_response 201
  end

  test "should show item" do
    get :show, id: @item
    assert_response :success

    get :show, id: @item, :format => :json
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @item
    assert_response :success
  end

  test "should update item" do
    put :update, id: @item, item: { quantity: 2, product_id: @product.id, order_id: @order.id }
    assert_redirected_to item_path(assigns(:item))

    put :update, id: @item, item: { quantity: 3, product_id: @product.id, order_id: @order.id }, :format => :json
    assert_response 204
  end

  test "should destroy item" do
    assert_difference('Item.count', -1) do
      delete :destroy, id: @item
    end

    assert_redirected_to items_path

    assert_difference('Item.count', -1) do
      delete :destroy, id: @item2, :format => :json
    end

    assert_response 204
  end
end
