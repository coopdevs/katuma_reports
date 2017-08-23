Spree::Order.class_eval do
  belongs_to :order_cycle
  belongs_to :customer
end
