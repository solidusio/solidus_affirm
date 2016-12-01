module Spree
  module Api
    class AffirmController < Spree::Api::BaseController
      include Spree::Core::ControllerHelpers::Order
      include Spree::Core::ControllerHelpers::Auth

      def payload
        @order = current_order
      end
    end
  end
end
