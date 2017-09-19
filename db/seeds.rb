# Keep in mind this seed records are coupled to Open Food Network ones. It is
# assumed the records OFN adds as seed data are present in the database when
# this seed data is executed.

enterprise_2 = Enterprise.find_by_name('Enterprise 2')
monthly_order_cycle = OrderCycle.find_by_name('Monthly order cycle')

order = Spree::Order.new
order.distributor_id = enterprise_2.id
order.order_cycle_id = monthly_order_cycle.id
order.save!

tomatoes_variant = Spree::Product.find_by_name('Tomatoes').variants.first
tomato_line_item = Spree::LineItem.new(
  variant_id: tomatoes_variant.id,
  quantity: 2
)
tomato_line_item.price = tomatoes_variant.price
order.line_items << tomato_line_item

garlic_variant = Spree::Product.find_by_name('Garlic').variants.first
garlic_line_item = Spree::LineItem.new(
  variant_id: garlic_variant.id,
  quantity: 3
)
garlic_line_item.price = garlic_variant.price
order.line_items << garlic_line_item

billing_address = Spree::Address.create!(
  firstname: 'Guest',
  lastname: 'Buyer',
  address1: 'No Name Ave',
  city: 'Melbourne',
  zipcode: 6666,
  phone: 666908976,
  state_id: Spree::State.find_by_name('ACT').id,
  country_id: Spree::Country.find_by_iso('AU').id
)

pick_up = Spree::ShippingMethod.find_by_name('Pickup')
order.shipping_method = pick_up
order.shipments.create!(
  shipping_method_id: pick_up.id
)

order.payments.create!(
  amount: 2.0,
  payment_method_id: 1
)

order.bill_address_id = billing_address.id
order.ship_address_id = billing_address.id
byebug
order.save!
