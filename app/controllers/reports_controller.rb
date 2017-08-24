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
    #
    # In Rails 3.2 (that I know of) when using #includes #select has no effect...
    # See: https://stackoverflow.com/questions/4047833/rails-3-select-with-include
    orders = Spree::Order
      .joins(:order_cycle)
      .includes(:customer)
      .uniq
      .where(order_cycles: { id: order_cycle.id })
      .order('customers.name ASC')

    products = Spree::Product
      .joins(variants: { line_items: { order: :order_cycle } })
      .uniq
      .where(order_cycles: { id: order_cycle.id })
      .select('spree_products.name, spree_variants.id AS variant_id')

    products_by_variant_id = products.group_by(&:variant_id)

    line_items = Spree::LineItem
      .joins(order: [:order_cycle, :customer])
      .group('customers.id, spree_line_items.variant_id, spree_line_items.order_id, spree_line_items.quantity')
      .select([:variant_id, :order_id, :quantity])

    line_items_by_variant_id = line_items.group_by(&:variant_id)

    render :show, locals: {
      orders: orders,
      products_by_variant_id: products_by_variant_id,
      line_items_by_variant_id: line_items_by_variant_id
    }
  end

  private

  def order_cycle
    OrderCycle.find(params[:id])
  end
end
