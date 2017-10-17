KatumaReports::Application.routes.draw do
  devise_for :spree_user, class_name: 'Spree::User'

  root controller: :reports, action: :index

  scope '/admin' do
    scope '/reports' do
      resources :variants_by_order, only: %i[index], path: 'order_cycle_management'

      # This will match any URL like /admin/reports/<report_name> not matched
      # by any of the previous declarations. Remember that Rails evaluates the
      # routes from top to bottom.
      get '/:report', controller: :reports, action: :index
    end
  end
end
