KatumaReports::Application.routes.draw do
  devise_for :spree_user, class_name: 'Spree::User'

  root to: 'admin/reports#index'

  scope '/admin' do
    resources :reports, only: %i[index]

    scope '/reports' do
      resources :variants_by_order, only: %i[index]
    end
  end
end
