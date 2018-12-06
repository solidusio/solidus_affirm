module SolidusAffirm
  module CallbackHook
    class Base
      def authorize!(payment)
        payment.process!
        authorized_affirm = Affirm::Charge.find(payment.response_code)
        payment.amount = authorized_affirm.amount / 100.0
        payment.save!
        payment.order.next! if payment.order.payment?
      end

      def after_authorize_url(order)
        order_state_checkout_path(order)
      end

      def after_cancel_url(order)
        order_state_checkout_path(order)
      end

      private

      def order_state_checkout_path(order)
        Spree::Core::Engine.routes.url_helpers.checkout_state_path(order.state)
      end
    end
  end
end
