require 'spec_helper'

describe Spree::Gateway::Affirm do
  let(:affirm_payment) { FactoryGirl.create(:affirm_payment) }
  let(:affirm_checkout) { FactoryGirl.create(:affirm_checkout) }

  describe '#provider_class' do
    it "returns the Affirm ActiveMerchant class" do
      expect(affirm_payment.payment_method.provider_class).to be(ActiveMerchant::Billing::Affirm)
    end
  end

  describe '#payment_source_class' do
    it "returns the affirm_checkout class" do
      expect(affirm_payment.payment_method.payment_source_class).to be(Spree::AffirmCheckout)
    end
  end

  describe '#source_required?' do
    it "returns true" do
      expect(affirm_payment.payment_method.source_required?).to be(true)
    end
  end

  describe '#method_type?' do
    it 'returns "affirm"' do
      expect(affirm_payment.payment_method.method_type).to eq("affirm")
    end
  end

  describe '#actions?' do
    it "retuns capture, void and credit" do
      expect(affirm_payment.payment_method.actions).to eq(['capture', 'void', 'credit'])
    end
  end

  describe '#supports?' do
    it "returns true if the source is an AffirmCheckout" do
      expect(affirm_payment.payment_method.supports?(affirm_checkout)).to be(true)
    end

    it "returns false when the source is not an affirm" do
      expect(affirm_payment.payment_method.supports?(6)).to be(false)
      expect(affirm_payment.payment_method.supports?(affirm_payment)).to be(false)
      expect(affirm_payment.payment_method.supports?(Spree::Order.new)).to be(false)
    end
  end

  describe "#cancel" do
    context "when there is no payment with the given charge_ari" do
      it "returns nil" do
        expect(affirm_payment.payment_method.cancel("xxxx-xxxx")).to be(nil)
      end
    end

    context "when the payment is in a completed state" do
      before(:each) do
        affirm_payment.stub(:completed?).and_return true
        affirm_payment.state = "completed"
        affirm_payment.save
      end

      context "when credit_allowed amount is > 0" do
        it "calls credit! on the payment with the credit_allowed amount" do
          Spree::Payment.stub_chain(:valid, :where, :first).and_return(affirm_payment)
          affirm_payment.stub(:can_credit?).and_return(true)
          expect(affirm_payment).to receive(:credit!).and_return false
          affirm_payment.payment_method.cancel affirm_payment.response_code
        end

        it "creates an adjustment for the -credit_allowed amount" do
          Spree::Payment.stub_chain(:valid, :where, :first).and_return(affirm_payment)
          affirm_payment.stub(:can_credit?).and_return(true)
          expect(affirm_payment).to receive(:credit!).and_return false
          payment_amount = affirm_payment.credit_allowed
          affirm_payment.payment_method.cancel affirm_payment.response_code

          expect(affirm_payment.order.adjustments.count).to be > 0
          expect(affirm_payment.order.adjustments.last.amount).to eq(-payment_amount)
        end
      end

      context "when credit_allowed amount is 0" do
        it "does not credit the payment" do
          Spree::Payment.stub_chain(:valid, :where, :first).and_return(affirm_payment)
          affirm_payment.stub(:can_credit?).and_return(false)
          expect(affirm_payment).not_to receive(:credit!)
          affirm_payment.payment_method.cancel affirm_payment.response_code
        end
      end
    end

    context "when the payment is in a failed state" do
      before do
        affirm_payment.state = "failed"
        affirm_payment.save
      end

      it "does nothing" do
        expect(affirm_payment).not_to receive(:credit!)
        expect(affirm_payment).not_to receive(:void_transaction!)
        affirm_payment.payment_method.cancel affirm_payment.response_code
      end
    end

    context "when the payment is in an invalid state" do
      before do
        affirm_payment.state = "invalid"
        affirm_payment.save
      end

      it "does nothing" do
        expect(affirm_payment).not_to receive(:credit!)
        expect(affirm_payment).not_to receive(:void_transaction!)
        affirm_payment.payment_method.cancel affirm_payment.response_code
      end
    end

    context "when the payment is in a pending state" do
      before do
        affirm_payment.stub(:pending?).and_return true
        affirm_payment.state = "pending"
        affirm_payment.save
      end

      it "voids the transaction" do
        Spree::Payment.stub_chain(:valid, :where, :first).and_return(affirm_payment)
        expect(affirm_payment).not_to receive(:credit!)
        expect(affirm_payment).to receive(:void_transaction!).and_return false
        affirm_payment.payment_method.cancel affirm_payment.response_code
      end
    end
  end
end
