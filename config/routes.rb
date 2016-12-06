Spree::Core::Engine.routes.draw do
  namespace :api, defaults: { format: 'json' } do
    resource :affirm, only: [], controller: 'affirm' do
      get :payload
    end
  end

  post '/affirm/confirm', to: "affirm#confirm", as: :confirm_affirm
  get '/affirm/cancel', to: "affirm#cancel", as: :cancel_affirm
end
