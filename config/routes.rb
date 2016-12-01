Spree::Core::Engine.routes.draw do
  namespace :api, defaults: { format: 'json' } do
    resource :affirm, only: [], controller: 'affirm' do
      get :payload
    end
  end
end
