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
      begin
        response = ::Affirm::Client.new.authorize(affirm_source.token)
        return ActiveMerchant::Billing::Response.new(true, "Transaction Approved", {}, authorization: response.id)
      rescue Exception => e
        return ActiveMerchant::Billing::Response.new(false, e.message)
      end
    end

    def capture(_money, charge_id, _options = {})
      begin
        response = ::Affirm::Client.new.capture(charge_id)
        return ActiveMerchant::Billing::Response.new(true, "Transaction Captured")
      rescue Exception => e
        return ActiveMerchant::Billing::Response.new(false, e.message)
      end
    end

    def void(charge_id, _money, _options = {})
      begin
        response = ::Affirm::Client.new.void(charge_id)
        return ActiveMerchant::Billing::Response.new(true, "Transaction Voided")
      rescue Exception => e
        return ActiveMerchant::Billing::Response.new(false, e.message)
      end
    end

    def credit(money, charge_id, _options = {})
      begin
        response = ::Affirm::Client.refund(charge_id, amount: money)
        return ActiveMerchant::Billing::Response.new(true, "Transaction Credited with #{money}")
      rescue Exception => e
        return ActiveMerchant::Billing::Response.new(false, e.message)
      end
    end
  end
end
