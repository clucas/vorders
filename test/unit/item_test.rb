# == Schema Information
#
# Table name: items
#
#  id         :integer          not null, primary key
#  quantity   :integer          default(1), not null
#  order_id   :integer
#  product_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  test "quantity greater than 0" do
    product1_net_price = 100.0
    order = Order.create(:name => "order", :order_on => Date.parse(Time.now.utc.to_s))
    product1 = Product.create(:name => "product1", :net_price => product1_net_price, :currency => "USD")
    line_item = Item.create(:order => order, :product => product1, :quantity => 0)
    assert !line_item.valid?
    assert_equal("quantity", line_item.errors.messages.keys.first.to_s)

    line_item = Item.create(:order => order, :product => product1, :quantity => 1)
    assert line_item.valid?
  end
  
  test "json response includes the product name" do
    product_net_price = 100.0
    product_name = "product"
    order = Order.create(:name => "order", :order_on => Date.parse(Time.now.utc.to_s))
    product1 = Product.create(:name => product_name, :net_price => product_net_price, :currency => "USD")
    line_item = Item.create(:order => order, :product => product1, :quantity => 0)
    assert_equal product_name, JSON.parse(line_item.to_json)["product_name"]
  end

  test "uniqueness of line item" do
    order = FactoryGirl.create(:order)
    product = FactoryGirl.create(:product)
    item = FactoryGirl.create(:item, :product => product, :order => order )
    assert_raise(ActiveRecord::RecordNotUnique) {Item.create(:order => order, :product => product, :quantity => 1)}
  end
end
