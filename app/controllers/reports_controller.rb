class ReportsController < ActionController::Base
  before_filter :authenticate_spree_user!

  def index
  end
end
