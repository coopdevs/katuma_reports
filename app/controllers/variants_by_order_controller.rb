# Renders the VariantsByOrderReport report
class VariantsByOrderController < ActionController::Base
  layout 'application'

  def index
    render :index, locals: {
      orders_including_customer: variants_by_order_report.orders_including_customer,
      products_by_variant_id: variants_by_order_report.products_by_variant_id,
      variants_by_order_report: variants_by_order_report
    }
  end

  private

  def order_cycle
    OrderCycle.find(params[:order_cycle_id])
  end

  def variants_by_order_report
    VariantsByOrderReport.new(order_cycle)
  end
end
