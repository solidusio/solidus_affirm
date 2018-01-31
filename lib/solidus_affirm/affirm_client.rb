require 'affirm'

module SolidusAffirm
  # Wrapper around using the Affirm API client for the Affirm Gateway.
  # It will communicate with Affirm and return the expected response
  # classes to the Gateway.
  #
  class AffirmClient
    def initialize(options)
      ::Affirm.configure do |config|
        config.public_api_key  = options[:public_api_key]
        config.private_api_key = options[:private_api_key]
        config.environment     = options[:test_mode] ? :sandbox : :production
      end
    end

    def authorize(_money, affirm_source, _options = {})
      response = ::Affirm::Charge.authorize(affirm_source.token)
      if response.success?
        ActiveMerchant::Billing::Response.new(true, "Transaction approved", {}, authorization: response.id)
      else
        ActiveMerchant::Billing::Response.new(false, response.error.message)
      end
    end

    def capture(_money, charge_id, _options = {})
      response = ::Affirm::Charge.capture(charge_id)
      if response.success?
        ActiveMerchant::Billing::Response.new(true, "Transaction Captured")
      else
        ActiveMerchant::Billing::Response.new(false, response.error.message)
      end
    end

    def void(charge_id, _money, _options = {})
      response = ::Affirm::Charge.void(charge_id)
      if response.success?
        return ActiveMerchant::Billing::Response.new(true, "Transaction Voided")
      else
        return ActiveMerchant::Billing::Response.new(false, response.error.message)
      end
    end

    def credit(money, charge_id, _options = {})
      response = ::Affirm::Charge.refund(charge_id, amount: money)
      if response.success?
        return ActiveMerchant::Billing::Response.new(true, "Transaction Credited with #{money}")
      else
        return ActiveMerchant::Billing::Response.new(false, response.error.message)
      end
    end
  end
end
