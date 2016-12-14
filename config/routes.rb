Spree::Core::Engine.routes.draw do
  post '/affirm/confirm', to: "affirm#confirm", as: :confirm_affirm
  get '/affirm/cancel', to: "affirm#cancel", as: :cancel_affirm
end
