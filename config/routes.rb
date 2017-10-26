KatumaReports::Application.routes.draw do
  devise_for :spree_user, class_name: 'Spree::User'

  root controller: :reports, action: :index

  scope '/admin' do
    scope '/reports' do
      get '/order_cycle_management', controller: :reports, action: :index

      scope '/order_cycle_management' do
        resources :variants_by_order, only: %i[index]

        match '/delayed_job' => DelayedJobWeb, anchor: false, via: [:get, :post]
      end
    end
  end
end
