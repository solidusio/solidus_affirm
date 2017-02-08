Spree::Core::Engine.routes.draw do
  scope :affirm do
    post 'confirm', controller: SolidusAffirm::Config.callback_controller_name, as: :confirm_affirm
    get 'cancel', controller: SolidusAffirm::Config.callback_controller_name, as: :cancel_affirm
  end
end
