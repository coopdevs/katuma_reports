class ReportsController < ActionController::Base
  SHOWED_ORDER_CYCLES = 10

  layout 'application'

  before_filter :authenticate_spree_user!

  def index
    render :index, locals: { order_cycles: last_order_cycles }
  end

  private

  def last_order_cycles
    OrderCycle
      .joins(coordinator: :enterprise_roles)
      .where(enterprise_roles: { user_id: current_spree_user.id })
      .order('order_cycles.created_at DESC')
      .limit(SHOWED_ORDER_CYCLES)
  end
end
