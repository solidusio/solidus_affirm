module SolidusAffirm
  class Gateway < Spree::Gateway
    preference :public_api_key, :string
    preference :private_api_key, :string
    preference :javascript_url, :string

    def provider_class
      AffirmClient
    end

    def payment_source_class
      SolidusAffirm::Checkout
    end

    def source_required?
      true
    end

    def method_type
      'affirm'
    end

    def supports?(source)
      source.is_a? payment_source_class
    end

    def payment_profiles_supported?
      false
    end

    # Affirm doesn't have a purcase endpoint
    # so autocapture doesn't make sense. Especially because you have to
    # leave the store and come back to confirm your order. Stores should
    # capture affirm payments after the order transitions to complete.
    # @return false
    def auto_capture
      false
    end

    # Will either refund or void the payment depending on its state.
    #
    # If the transaction has not yet been captured, we can void the transaction.
    # Otherwise, we need to issue a refund.
    def cancel(charge_id)
      provider

      begin
        transaction = ::Affirm::Charge.find(charge_id)
      # workaround: on 404 responses we get XML data from the API.
      # the affirm-ruby gem doesn't handle non-JSON responses at the moment.
      rescue NoMethodError
        return ActiveMerchant::Billing::Response.new(false, "Affirm charge not found")
      end

      unless transaction.success?
        return ActiveMerchant::Billing::Response.new(false, transaction.error.message)
      end

      if voidable?(transaction)
        void(charge_id, nil, {})
      else
        credit(nil, charge_id, {})
      end
    end

    private

    def voidable?(transaction)
      transaction.status == "authorized"
    end
  end
end
