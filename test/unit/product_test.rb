# == Schema Information
#
# Table name: products
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  net_price  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  currency   :string(255)
#

require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  test "name is unique" do
    Product.create(:name => "product", :net_price => 1000)
    assert_raise(ActiveRecord::RecordNotUnique) {Product.create(:name => "product", :net_price => 1000)}
  end
  
  test "product can't be destroyed when belonging to order" do
    product1_net_price = 100.0
    order = Order.create(:name => "order", :order_on => Date.today)
    product1 = Product.create(:name => "product1", :net_price => product1_net_price, :currency => "USD")
    line_item = Item.create(:order => order, :product => product1, :quantity => 1)
    assert !product1.destroy
    assert !product1.errors.empty?
    assert_equal I18n.translate(:destroy_error_message), product1.errors.full_messages.first
  end
end
