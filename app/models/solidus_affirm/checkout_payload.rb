require 'active_model_serializers'

module SolidusAffirm
  # This class represents the json payload needed for the Affirm checkout.
  # It will escapsulate the +Spree::Order+ and the needed configuration and
  # meta data that will be serialized and send as JSON to Affirm.
  #
  # @!attribute [r] order
  #   [Spree::Order] The +Spree::Order+ instance that will be send to Affirm by
  #   serializing this Object.
  # @!attribute [r] config
  #   [Hash] The configuration for Affirm, this hash expects the following keys:
  #   +:user_confirmation_url+ and +:user_cancel_url+
  #   and if you specify the optional +:name+ configuration, that will also be used.
  # @!attribute [r] metadata
  #   [Hash] Affirm support arbitrary key:value metadata, we pass this hash
  #   directly to Affirm if it's present.
  # @see CheckoutPayloadSerializer
  class CheckoutPayload < ActiveModelSerializers::Model
    attr_reader :order, :config, :metadata

    # @param order [Spree::Order]
    # @param config [Hash]
    # @option config [String] :user_confirmation_url The redirect url for succesful Affirm checkout
    # @option config [String] :user_cancel_url The redirect url for a canceled Affirm checkout
    # @option config [String] :name The shop name to display in the Affirm checkout.
    # @param metadata [Hash]
    def initialize(order, config, metadata = {})
      @order = order
      @config = config
      @metadata = metadata
    end

    def ship_address
      order.ship_address
    end

    def bill_address
      order.bill_address
    end

    def items
      order.line_items
    end
  end
end
