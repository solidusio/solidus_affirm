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

    # Allows implementing custom controller for handling the confirming
    #  and canceling callbacks from Affirm.
    # @!attribute [rw] callback_controller_name
    # @see Spree::AffirmController
    # @return [String] The controller name used in the routes file.
    #   The standard controller is the 'affirm' controller
    attr_writer :callback_controller_name
    def callback_controller_name
      @callback_controller_name ||= "affirm"
    end

    # Allows overriding the main checkout payload serializer
    # @!attribute [rw] checkout_payload_serializer
    # @see SolidusAffirm::CheckoutPayloadSerializer
    # @return [Class] The serializer class that will be used for serializing
    #  the +SolidusAffirm::CheckoutPayload+ object.
    attr_writer :checkout_payload_serializer
    def checkout_payload_serializer
      @checkout_payload_serializer ||= SolidusAffirm::CheckoutPayloadSerializer
    end

    attr_writer :exchange_lease_enabled
    def exchange_lease_enabled
      @exchange_lease_enabled ||= false
    end
  end
end
