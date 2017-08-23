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
    customers = Customer
      .joins(orders: :order_cycle)
      .where(order_cycles: { id: order_cycle.id })

    products = Spree::Product
      .joins(variants: { line_items: { order: :order_cycle } })
      .where(order_cycles: { id: order_cycle.id })

    render :show, locals: { customers: customers, products: products }
  end

  private

  def order_cycle
    OrderCycle.find(params[:id])
  end
end
