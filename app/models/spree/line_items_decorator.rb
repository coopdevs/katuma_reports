Spree::LineItem.class_eval do
  scope :for_order_cycle, ->(order_cycle) { where(order_cycles: { id: order_cycle.id }) }
end
