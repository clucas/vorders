require 'test_helper'

class ProductsControllerTest < ActionController::TestCase
  setup do
    @product = FactoryGirl.create(:product)
    @product2 = FactoryGirl.create(:product)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:products)

    get :index
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success

    get :new
    assert_response :success
  end

  test "should create product" do
    assert_raise(ActiveRecord::RecordNotUnique) {post :create, product: { name: @product.name, net_price: @product.net_price }}
    assert_difference('Product.count') do
      post :create, product: { name: "product_name", net_price: @product.net_price }
    end

    assert_redirected_to product_path(assigns(:product))


    assert_raise(ActiveRecord::RecordNotUnique) {post :create, product: { name: @product.name, net_price: @product.net_price }, :format => :json}
    assert_difference('Product.count') do
      post :create, product: { name: "different name", net_price: @product.net_price }, :format => :json
    end

    assert_response 201
  end

  test "should show product" do
    get :show, id: @product
    assert_response :success
    
    get :show, id: @product, :format => :json
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @product
    assert_response :success
  end

  test "should update product" do
    put :update, id: @product, product: { name: "product1", net_price: @product.net_price }
    assert_redirected_to product_path(assigns(:product))

    put :update, id: @product, product: { name: "product2", net_price: @product.net_price }, :format => :json
    assert_response 204
  end

  test "should destroy product" do
    assert_difference('Product.count', -1) do
      delete :destroy, id: @product
    end

    assert_redirected_to products_path

    assert_difference('Product.count', -1) do
      delete :destroy, id: @product2, :format => :json
    end

    assert_response 204
  end
end
