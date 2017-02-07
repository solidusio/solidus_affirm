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

    # Affirm doesn't have a purcase endpoint
    # so autocapture doesn't make sense. Especially because you have to
    # leave the store and come back to confirm your order. Stores should
    # capture affirm payments after the order transitions to complete.
    # @return false
    def auto_capture
      false
    end
  end
end
