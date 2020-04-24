module Spree
  class AffirmController < Spree::StoreController
    protect_from_forgery except: [:confirm]

    def confirm
      checkout_token = affirm_params[:checkout_token]
      order = Spree::Order.find(affirm_params[:order_id])

      if !checkout_token
        return redirect_to checkout_state_path(order.state), notice: "Invalid order confirmation data passed in"
      end

      if order.complete?
        return redirect_to spree.order_path(order), notice: "Order is already in complete state"
      end

      affirm_transaction = Affirm::Client.new.read_transaction(checkout_token)
      provider = SolidusAffirm::Checkout::PROVIDERS[affirm_transaction.provider_id - 1]
      affirm_checkout = SolidusAffirm::Checkout.new(token: checkout_token, provider: provider)

      affirm_checkout.transaction do
        if affirm_checkout.save!
          payment = order.payments.create!({
            payment_method_id: affirm_params[:payment_method_id],
            source: affirm_checkout
          })
          hook = SolidusAffirm::Config.callback_hook.new
          hook.authorize!(payment)
          hook.remove_tax!(order) if provider == "katapult"
          redirect_to hook.after_authorize_url(order)
        end
      end
    end

    def cancel
      order = Spree::Order.find(affirm_params[:order_id])
      hook = SolidusAffirm::Config.callback_hook.new
      redirect_to hook.after_cancel_url(order)
    end

    private

    def affirm_params
      params.permit(:checkout_token, :payment_method_id, :order_id)
    end
  end
end
