require 'spec_helper'

RSpec.describe SolidusAffirm::AffirmClient do
  let(:gateway_options) do
    {
      public_api_key: "XPSQ3CA7PLN7CJCK",
      private_api_key: "w9mxkQUryKjTYDqOfSvYTeTGoLIURKpU",
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
    it "will authorize the affirm payment with the checkout token" do
      VCR.use_cassette("valid_authorize") do
        response = subject.authorize(nil, affirm_payment_source, {})
        expect(response.success?).to be_truthy
      end
    end

    context "with invalid data" do
      let(:checkout_token) { "FOOBAR" }

      it "will return an unsuccesfull response" do
        VCR.use_cassette("invalid_authorize") do
          response = subject.authorize(nil, affirm_payment_source, {})
          expect(response.success?).to be_falsey
        end
      end

      it "will return the error message from Affirm in the response" do
        VCR.use_cassette("invalid_authorize") do
          response = subject.authorize(nil, affirm_payment_source, {})
          expect(response.message).to eql "Invalid Request"
        end
      end
    end
  end

  describe "#capture" do
    it "will capture the affirm payment with the charge_id" do
      VCR.use_cassette("valid_capture") do
        response = subject.capture(nil, charge_id, {})
        expect(response.success?).to be_truthy
      end
    end

    context "with invalid data" do
      it "will return an unsuccesfull response" do
        VCR.use_cassette("invalid_capture") do
          response = subject.capture(nil, charge_id, {})
          expect(response.success?).to be_falsey
        end
      end

      it "will return the error message from Affirm in the response" do
        VCR.use_cassette("invalid_capture") do
          response = subject.capture(nil, charge_id, {})
          expect(response.message).to eql "Duplicate capture"
        end
      end
    end
  end

  describe "#void" do
    context "on an authorized payment" do
      let(:charge_id) { "X0KF-8HQY" }
      it "will void the payment in Affirm" do
        VCR.use_cassette("valid_void") do
          response = subject.void(charge_id, nil, {})
          expect(response.success?).to be_truthy
        end
      end
    end

    context "on a captured payment" do
      it "will return an unsuccesfull response" do
        VCR.use_cassette("invalid_void") do
          response = subject.void(charge_id, nil, {})
          expect(response.success?).to be_falsey
        end
      end

      it "will return the error message from Affirm in the response" do
        VCR.use_cassette("invalid_void") do
          response = subject.void(charge_id, nil, {})
          expect(response.message).to eql "Cannot void captured charge"
        end
      end
    end
  end

  describe "#credit" do
    context "on an captured payment" do
      it "will refund a part or the whole payment amount" do
        VCR.use_cassette("valid_partial_credit") do
          response = subject.credit(1000, charge_id, {})
          expect(response.success?).to be_truthy
        end
      end
    end

    context "on an already voided payment" do
      let(:charge_id) { "X0KF-8HQY" }

      it "will return an unsuccesfull response" do
        VCR.use_cassette("invalid_credit") do
          response = subject.credit(10_000, charge_id, {})
          expect(response.success?).to be_falsey
        end
      end

      it "will return the error message from Affirm in the response" do
        VCR.use_cassette("invalid_credit") do
          response = subject.credit(10_000, charge_id, {})
          expect(response.message).to eql "Cannot refund voided charge."
        end
      end
    end
  end
end
