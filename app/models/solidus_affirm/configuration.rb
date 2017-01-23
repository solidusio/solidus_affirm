module SolidusAffirm
  class Configuration < Spree::Preferences::Configuration
    # Allows implementing custom callback hook for confirming and canceling
    #  callbacks from Affirm.
    # @!attribute [rw] callback_hook
    # @see SolidusAffirm::CallbackHook::Base
    # @return [Class] an object that conforms to the API of
    #   the standard callback hook class SolidusAffirm::CallbackHook::Base.
    attr_writer :callback_hook
    def callback_hook
      @callback_hook ||= SolidusAffirm::CallbackHook::Base
    end
  end
end
