Spree::Core::Engine.routes.draw do
  scope :affirm do
    post 'confirm', to: "affirm#confirm", as: :confirm_affirm
    get 'cancel', to: "affirm#cancel", as: :cancel_affirm
  end
end
