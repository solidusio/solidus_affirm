require "spec_helper"

RSpec.describe SolidusAffirm::Gateway do
  let(:gateway) do
    create(:affirm_payment_gateway,
           preferred_public_api_key: "XPSQ3CA7PLN7CJCK",
           preferred_private_api_key: "w9mxkQUryKjTYDqOfSvYTeTGoLIURKpU")
  end
  let(:authorized_id) { "GOH6-7PUX" }
  let(:captured_id) { "N330-Z6D4" }

  describe "#cancel" do
    let(:transaction_id) { "fake_transaction_id" }

    subject(:cancel) { gateway.cancel(transaction_id) }

    context "when the transaction is found" do
      context "and it is voidable" do
        let(:transaction_id) { authorized_id }

        xit "voids the transaction" do
        end
      end

      context "and it is not voidable" do
        let(:transaction_id) { captured_id }

        xit "refunds the transaction" do
        end
      end
    end

    context "when the transaction is not found" do
      xit "raises an error" do
      end
    end
  end

  describe "#try_void" do
    let(:transaction_id) { "fake_transaction_id" }

    subject(:try_void) { gateway.try_void(instance_double('Spree::Payment', response_code: transaction_id)) }

    context "when the transaction is found" do
      context "and it is voidable" do
        let(:transaction_id) { authorized_id }

        xit "voids the transaction" do
        end
      end

      context "and it is not voidable" do
        let(:transaction_id) { captured_id }

        xit "returns false" do
        end
      end
    end

    context "when the transaction is not found" do
      xit "raises an error" do
      end
    end
  end
end
