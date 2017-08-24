class ReportsController < ActionController::Base
  SHOWED_ORDER_CYCLES = 10

  layout 'application'

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
    variants_by_order_report = VariantsByOrderReport.new(order_cycle)

    render :show, locals: {
      orders: variants_by_order_report.orders,
      products_by_variant_id: variants_by_order_report.products_by_variant_id,
      line_items_by_variant_id: variants_by_order_report.line_items_by_variant_id
    }
  end

  private

  def order_cycle
    OrderCycle.find(params[:id])
  end
end
