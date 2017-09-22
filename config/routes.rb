KatumaReports::Application.routes.draw do
  devise_for :spree_user, class_name: 'Spree::User'

  root controller: :reports, action: :index

  scope '/admin' do
    scope '/reports' do
      get '/orders_and_fulfillment', controller: :reports, action: :index

      resources :variants_by_order, only: %i[index]
    end
  end
end
