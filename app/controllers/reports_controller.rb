class ReportsController < ActionController::Base
  SHOWED_ORDER_CYCLES = 10

  before_filter :authenticate_spree_user!

  def index
    order_cycles = OrderCycle
      .joins(coordinator: :enterprise_roles)
      .where(enterprise_roles: { user_id: current_spree_user.id })
      .order('order_cycles.created_at DESC')
      .limit(SHOWED_ORDER_CYCLES)

    render :index, locals: { order_cycles: order_cycles }
  end

  def show
    # TODO: Make customer name header match the correct quantity. Now the
    # quantity showed in the cell is the one belonging to the customer by pure
    # chance
    customers = Customer
      .joins(orders: :order_cycle)
      .uniq
      .where(order_cycles: { id: order_cycle.id })
      .order(:name)
      .pluck(:name)

    products = Spree::Product
      .joins(variants: { line_items: { order: :order_cycle } })
      .uniq
      .where(order_cycles: { id: order_cycle.id })
      .select('spree_products.name, spree_variants.id AS variant_id')
      .group_by(&:variant_id)

    line_items = Spree::LineItem
      .joins(order: [:order_cycle, :customer])
      .group('customers.name, spree_line_items.variant_id, spree_line_items.quantity')
      .select([:variant_id, :quantity])

    variants_with_line_items = line_items.group_by(&:variant_id)

    render :show, locals: {
      customers: customers,
      products: products,
      variants_with_line_items: variants_with_line_items
    }
  end

  private

  def order_cycle
    OrderCycle.find(params[:id])
  end
end
