class ReportsController < ActionController::Base
  before_filter :authenticate_spree_user!

  def index
    order_cycles = OrderCycle
      .joins(coordinator: :enterprise_roles)
      .where(enterprise_roles: { user_id: current_spree_user.id })

    render :index, locals: { order_cycles: order_cycles }
  end
end
