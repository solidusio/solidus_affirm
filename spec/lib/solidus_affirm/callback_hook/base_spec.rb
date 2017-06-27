require 'spec_helper'

RSpec.describe SolidusAffirm::CallbackHook::Base do
  let(:order) { create(:order_with_totals, state: "payment") }
  let(:payment_method) do
    create(
      :affirm_payment_gateway,
      preferred_public_api_key: "XPSQ3CA7PLN7CJCK",
      preferred_private_api_key: "w9mxkQUryKjTYDqOfSvYTeTGoLIURKpU",
      preferred_test_mode: true
    )
  end
  let(:checkout_token) { "26VJRAAYE0MB0V25" }
  let(:affirm_payment_source) { create(:affirm_checkout, token: checkout_token) }
  let(:payment) do
    create(
      :payment,
      response_code: nil,
      order: order,
      source: affirm_payment_source,
      payment_method: payment_method
    )
  end

  subject { SolidusAffirm::CallbackHook::Base.new }

  describe "authorize!" do
    context "with a valid payment setup" do
      it "will set the payment amount to the affirm amount" do
        VCR.use_cassette 'callback_hook_authorize_success' do
          expect { subject.authorize!(payment) }.to change{ payment.amount }.from(0).to(424.99)
        end
      end

      it "will set the affirm charge id as the response_code on the payment" do
        VCR.use_cassette 'callback_hook_authorize_success' do
          expect { subject.authorize!(payment) }.to change{ payment.response_code }.from(nil).to("N330-Z6D4")
        end
      end

      it "moves the order to the next state" do
        VCR.use_cassette 'callback_hook_authorize_success' do
          expect { subject.authorize!(payment) }.to change{ order.state }.from("payment").to("confirm")
        end
      end
    end
  end
end
