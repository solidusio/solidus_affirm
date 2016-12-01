module Spree
  class AffirmController < Spree::StoreController
    helper 'spree/orders'

    #the confirm will do it's own protection by making calls to affirm
    protect_from_forgery :except => [:confirm]

    def confirm
      order = current_order || raise(ActiveRecord::RecordNotFound)

      if !params[:checkout_token]
        flash[:notice] = "Invalid order confirmation data."
        return redirect_to checkout_state_path(current_order.state)
      end

      if order.complete?
        flash[:notice] = "Order already completed."
        return redirect_to completion_route order
      end

      affirm_checkout = Spree::AffirmCheckout.new(
        order: order,
        token: params[:checkout_token],
        payment_method: payment_method
      )

      affirm_checkout.save

      affirm_payment = order.payments.create!({
        payment_method: payment_method,
        amount: order.total,
        source: _affirm_checkout
      })

      # transition to confirm or complete
      # FIXME there are better ways!
      while order.next; end

      if order.completed?
        session[:order_id] = nil
        flash.notice = Spree.t(:order_processed_successfully)
        flash[:order_completed] = true
        redirect_to completion_route order
      else
        redirect_to checkout_state_path(order.state)
      end
    end

    def cancel
      redirect_to checkout_state_path(current_order.state)
    end

    private

    def payment_method
      Spree::PaymentMethod.find(params[:payment_method_id])
    end

    def provider
      payment_method.provider
    end

    def completion_route(order)
      spree.order_path(order)
    end
  end
end
