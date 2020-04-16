require 'spec_helper'

RSpec.describe SolidusAffirm::AffirmClient do
  let(:gateway_options) do
    {
      public_api_key: "PUBLIC_API_KEY",
      private_api_key: "PRIVATE_API_KEY",
      test_mode: true
    }
  end

  let(:checkout_token) { "TKLKJ71GOP9YSASU" }
  let(:charge_id) { "N330-Z6D4" }
  let(:affirm_payment_source) { create(:affirm_checkout, token: checkout_token) }

  subject do
    SolidusAffirm::AffirmClient.new(gateway_options)
  end

  describe "#authorize" do
    xit "will authorize the affirm payment with the checkout token" do

    end

    context "with invalid data" do
      let(:checkout_token) { "FOOBAR" }

      xit "will return an unsuccesfull response" do

      end

      xit "will return the error message from Affirm in the response" do
      end
    end
  end

  describe "#capture" do
    xit "will capture the affirm payment with the charge_id" do
    end

    context "with invalid data" do
      xit "will return an unsuccesfull response" do
      end

      xit "will return the error message from Affirm in the response" do
      end
    end
  end

  describe "#void" do
    context "on an authorized payment" do
      xit "will void the payment in Affirm" do
      end
    end

    context "on a captured payment" do
      xit "will return an unsuccesfull response" do
      end
      xit "will return the error message from Affirm in the response" do
      end
    end
  end

  describe "#credit" do
    context "on an captured payment" do
      xit "will refund a part or the whole payment amount" do
      end
    end

    context "on an already voided payment" do
      let(:charge_id) { "X0KF-8HQY" }

      xit "will return an unsuccesfull response" do
      end

      xit "will return the error message from Affirm in the response" do
      end
    end
  end
end
