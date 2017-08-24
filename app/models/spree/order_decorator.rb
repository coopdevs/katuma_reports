Spree::Order.class_eval do
  belongs_to :order_cycle
  belongs_to :customer

  scope :completed, -> { where(state: 'complete') }
  scope :for_order_cycle, ->(order_cycle) { where(order_cycles: { id: order_cycle.id }) }
end
