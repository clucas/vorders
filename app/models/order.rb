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

class Order < ActiveRecord::Base
  attr_accessible :name, :reason, :order_on#, :order_action
  has_many :items
  has_many :products, :through => :items
  
  validates :order_on, :presence => true, :date => {:after_or_equal_to => Date.parse(Time.now.utc.to_s)}              
  

  include AASM              
  aasm :column => :status do
    state :draft, :initial => true 
    state :placed
    state :paid
    state :cancelled

    event :place do
      transitions :to => :placed, :from => :draft, :guard => :can_order?
    end

    event :pay do
      transitions :to => :paid, :from => :placed
    end

    event :cancel do
      transitions :to => :cancelled, :from => [:draft, :placed], :guard => :can_cancel?
    end
  end
  
  def can_order?
    !self.items.empty?
  end
     
  def can_cancel?
    !self.reason.blank?
  end   
  
  def net_total
    self.items.collect{|x| x.quantity * x.product.net_price.to_d}.sum
  end
  
  def gross_total
    self.net_total * (1+@@vat)
  end

  def can_save_order?
    self.draft?
  end
  
  def update_with_params( params )
    if params[:order_action]
      self.reason = params[:reason]
      update_state(params[:order_action])
    else
      update_attributes(params)
    end
  end

  def update_state(order_action)
    begin
      self.send("#{order_action}!")
    rescue Exception => e
      messahe_help = ""
      message_help = "reason is needed" if order_action.eql?("cancel") 
      message_help = "line item is needed" if order_action.eql?("place") 
      self.errors[:base] << "Action #{@order_action} unsuccessful #{message_help}"
    end
  end
  
  def as_json(options={})
    super(options.merge(:methods => [:net_total, :gross_total]))
  end
end
