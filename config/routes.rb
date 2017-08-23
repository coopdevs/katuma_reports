KatumaReports::Application.routes.draw do
  devise_for :spree_user, class_name: 'Spree::User'

  root to: 'reports#index'

  resources :reports, only: %i[index show]
end
