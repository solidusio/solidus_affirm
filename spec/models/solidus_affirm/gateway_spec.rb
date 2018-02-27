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

        it "voids the transaction" do
          VCR.use_cassette("valid_find_authorized") do
            expect(gateway).to receive(:void).with(transaction_id, nil, {})
            cancel
          end
        end
      end

      context "and it is not voidable" do
        let(:transaction_id) { captured_id }

        it "refunds the transaction" do
          VCR.use_cassette("valid_find_captured") do
            expect(gateway).to receive(:credit).with(nil, transaction_id, {})
            cancel
          end
        end
      end
    end

    context "when the transaction is not found" do
      it "raises an error" do
        VCR.use_cassette("invalid_find") do
          expect(cancel.message).to eq "Affirm charge not found"
        end
      end
    end
  end

  describe "#try_void" do
    let(:transaction_id) { "fake_transaction_id" }

    subject(:try_void) { gateway.try_void(transaction_id) }

    context "when the transaction is found" do
      context "and it is voidable" do
        let(:transaction_id) { authorized_id }

        it "voids the transaction" do
          VCR.use_cassette("valid_find_authorized") do
            expect(gateway).to receive(:void).with(transaction_id, nil, {})
            try_void
          end
        end
      end

      context "and it is not voidable" do
        let(:transaction_id) { captured_id }

        it "returns false" do
          VCR.use_cassette("valid_find_captured") do
            expect(try_void).to be false
          end
        end
      end
    end

    context "when the transaction is not found" do
      it "raises an error" do
        VCR.use_cassette("invalid_find") do
          expect(try_void.message).to eq "Affirm charge not found"
        end
      end
    end
  end
end
