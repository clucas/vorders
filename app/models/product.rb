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

class Product < ActiveRecord::Base
  attr_accessible :name, :net_price, :currency
  has_many :items
  
  before_destroy :check_for_orders
  
  composed_of :net_price,
              :class_name => 'Money',
              :mapping => [%w(net_price cents), %w(currency currency_as_string)],
              :constructor => Proc.new { |net_price, currency| Money.new(net_price, currency || Money.default_currency) },
              :converter => Proc.new { |value| value.respond_to?(:to_money) ? (value.to_f.to_money rescue Money.empty) : Money.empty }
  
  def check_for_orders
    if self.items.count > 0
      self.errors[:base] << I18n.translate(:destroy_error_message)
      return false
    end
  end
end
