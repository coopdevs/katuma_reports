class ReportsController < ActionController::Base
  before_filter :authenticate_spree_user!

  def index
    order_cycles = OrderCycle.all
    render :index, locals: { order_cycles: order_cycles }
  end
end
