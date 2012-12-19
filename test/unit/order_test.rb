# == Schema Information
#
# Table name: orders
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  reason     :string(255)
#  status     :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  order_on   :date             not null
#

require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  setup do
    @order = FactoryGirl.create(:order)
    @product = FactoryGirl.create(:product)
    @line_item = FactoryGirl.create(:item, :product => @product, :order => @order)    
  end
  
  test "order is initialized with draft status" do
    order = Order.new(:name => "order", :order_on => Date.parse(Time.now.utc.to_s))
    assert order.draft?
  end
  
  test "placing order" do
    assert @order.draft?
    @order.place!
    assert @order.placed?
  end

  test "cancelling draft order" do
    assert_raise(AASM::InvalidTransition)  {@order.cancel!}
    assert @order.draft?
    @order.update_attribute(:reason, "reason")
    @order.cancel!
    assert @order.cancelled?
  end

  test "cancelling placed order" do
    @order.place!
    assert @order.placed?
    assert_raise(AASM::InvalidTransition)  {@order.cancel!}
    assert @order.placed?
    @order.update_attribute(:reason, "reason")
    @order.cancel!
    assert @order.cancelled?
  end
  
  test "paying placed order" do
    # @order.place!
    @order.update_state("place")
    assert @order.placed?
    @order.pay!
    assert @order.paid?
    
  end

  test "date is valid" do
    order = Order.new(:name => "order1", :order_on => nil)
    order.save
    assert !order.valid?
    assert_equal("order_on", order.errors.messages.keys.first.to_s)
    order = Order.new(:name => "order1", :order_on => Date.parse(Time.now.utc.to_s) - 2.day)
    order.save
    assert !order.valid?
    assert_equal("order_on", order.errors.messages.keys.first.to_s)
    order = Order.new(:name => "order1", :order_on => Date.parse(Time.now.utc.to_s))
    order.save
    assert order.valid?
  end
  
  test "order price" do
    product1_net_price = 100.0
    product2_net_price = 200.0
    quantity1 = 1
    quantity2 = 2
    order = Order.create(:name => "order1", :order_on => Date.parse(Time.now.utc.to_s))
    product1 = Product.create(:name => "product1", :net_price => product1_net_price, :currency => "USD")
    product2 = Product.create(:name => "product2", :net_price => product2_net_price, :currency => "USD")
    line_item = Item.create(:order => order, :product => product1, :quantity => quantity1)
    line_item = Item.create(:order => order, :product => product2, :quantity => quantity2)
    assert_equal order.net_total, product1_net_price * quantity1 + product2_net_price * quantity2
    assert_equal order.gross_total, (product1_net_price * quantity1 + product2_net_price * quantity2) * 1.2
  end
  
  test "json response includes net total and gross total" do
    product_net_price = 100.0
    product_name = "product"
    order = Order.create(:name => "order", :order_on => Date.parse(Time.now.utc.to_s))
    product1 = Product.create(:name => product_name, :net_price => product_net_price, :currency => "USD")
    line_item = Item.create(:order => order, :product => product1, :quantity => 0)
    assert_equal order.net_total, JSON.parse(order.to_json)["net_total"]
    assert_equal order.gross_total, JSON.parse(order.to_json)["gross_total"]
  end
  
end
