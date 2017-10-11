KatumaReports::Application.routes.draw do
  devise_for :spree_user, class_name: 'Spree::User'

  root controller: :reports, action: :index

  scope '/admin' do
    scope '/reports' do
      resources :variants_by_order, only: %i[index]

      get '/:report', controller: :reports, action: :index
    end
  end
end
