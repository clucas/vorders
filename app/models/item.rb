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

class Item < ActiveRecord::Base
  belongs_to :order
  belongs_to :product
  attr_accessible :quantity, :order, :product, :order_id, :product_id
  validates :quantity, numericality: {only_integer: true, greater_than_or_equal_to: 1}
  
  before_save :can_save_order?              
    
  def can_save_order?
    self.order.can_save_order?
  end
  
  def product_name
    self.product.name
  end
  
  def as_json(options={})
    super(options.merge(:methods => [:product_name]))
  end
  
end
