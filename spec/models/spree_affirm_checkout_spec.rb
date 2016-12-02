require 'spec_helper'


describe Spree::AffirmCheckout do
  let(:valid_checkout) { FactoryGirl.create(:affirm_checkout) }
  let(:affirm_payment) { FactoryGirl.create(:affirm_payment) }


  describe "scopes" do
    describe "with_payment_profile" do
      it "returns all" do
        expect(Spree::AffirmCheckout.all).to eq(Spree::AffirmCheckout.with_payment_profile)
      end
    end


  end


  describe '#details' do
    it "calls get_checkout from the payment provider exactly once" do
      _checkout = FactoryGirl.build(:affirm_checkout, stub_details: false)
      _checkout.payment_method.provider.stub(:get_checkout) do
         {"hello" => "there"}
      end
      expect(_checkout.payment_method.provider).to receive(:get_checkout).exactly(1).times
      _checkout.details
      _checkout.details
      _checkout.details
    end
  end


  describe "#valid?" do
    context "with all valid checkout details" do
      it "should return true" do
        expect(valid_checkout.valid?).to be(true)
      end
    end
  end

  describe "#check_valid_products" do
    context "with all matching fields" do
      it "does not set an error" do
        valid_checkout.check_valid_products
        expect(valid_checkout.errors.size).to be(0)
      end

      it "does not throw an error for case senstive name mismatches" do
        _checkout = FactoryGirl.build(:affirm_checkout, full_name_case_mismatch: true)
        _checkout.check_matching_billing_address
        expect(_checkout.errors.size).to be(0)

      end
    end

    context "with an extra product is in the checkout details" do
      it "sets an error on line_items" do
        _checkout = FactoryGirl.build(:affirm_checkout, extra_line_item: true )
        _checkout.check_valid_products
        expect(_checkout.errors[:line_items]).to_not be_empty
      end
    end


    context "with the checkout details are missing a product" do
      it "sets an error on line_items" do
        _checkout = FactoryGirl.build(:affirm_checkout, missing_line_item: true )
        _checkout.check_valid_products
        expect(_checkout.errors[:line_items]).to_not be_empty
      end
    end

    context "with a line item has mismatched quantity" do
      it "sets an error for the item" do
        _checkout = FactoryGirl.build(:affirm_checkout, quantity_mismatch: true )
        _checkout.check_valid_products
        expect(_checkout.errors.size).to be(1)
      end
    end

    context "with a line item has mismatched price" do
      it "sets an error for the item" do
        _checkout = FactoryGirl.build(:affirm_checkout, price_mismatch: true )
        _checkout.check_valid_products
        expect(_checkout.errors.size).to be(1)
      end
    end

  end

  describe "#check_matching_billing_address" do
    context "with a matching billing address" do
      it "does not set any errors for the billing_address" do
        valid_checkout.check_matching_billing_address
        expect(valid_checkout.errors.size).to be(0)
        expect(valid_checkout.errors[:billing_address]).to be_empty
      end

      context "with alternate address format" do
        it "does not set any errors for the billing_address" do
          _checkout = FactoryGirl.build(:affirm_checkout, alternate_billing_address_format: true)
          valid_checkout.check_matching_billing_address
          expect(valid_checkout.errors.size).to be(0)
          expect(valid_checkout.errors[:billing_address]).to be_empty
        end
      end

      context "with a name.full instead of first/last" do
        it "does not set any error for the billing_address" do
          _checkout = FactoryGirl.build(:affirm_checkout, billing_address_full_name: true)
          _checkout.check_matching_billing_address
          expect(_checkout.errors[:billing_address]).to be_empty
        end
      end
    end

    context "with a mismtached billing address" do
      it "sets an error for the billing_address" do
        _checkout = FactoryGirl.build(:affirm_checkout, billing_address_mismatch: true)
        _checkout.check_matching_billing_address
        expect(_checkout.errors[:billing_address]).not_to be_empty
      end

      context "with alternate address format" do
        it "sets an error for the billing_address" do
          _checkout = FactoryGirl.build(:affirm_checkout, billing_address_mismatch: true, alternate_billing_address_format: true)
          _checkout.check_matching_billing_address
          expect(_checkout.errors[:billing_address]).not_to be_empty
        end
      end


      context "with a name.full instead of first/last" do
        it "sets an error for the billing_address" do
          _checkout = FactoryGirl.build(:affirm_checkout, billing_address_mismatch: true, billing_address_full_name: true)
          _checkout.check_matching_billing_address
          expect(_checkout.errors[:billing_address]).not_to be_empty
        end
      end
    end
  end



  describe "#check_matching_shipping_address" do
    context "with a matching shipping address" do
      it "does not set an error for the shipping_address" do
        valid_checkout.check_matching_shipping_address
        expect(valid_checkout.errors[:shipping_address]).to be_empty
      end
    end


    context "with a mismatched shipping address" do
      it "adds an error for the shipping_address" do
        _checkout = FactoryGirl.build(:affirm_checkout, shipping_address_mismatch: true)
        _checkout.check_matching_shipping_address
        expect(_checkout.errors[:shipping_address]).not_to be_empty
      end
    end
  end


  describe "#check_matching_billing_email" do
    context "with a matching billing email" do
      it "does not set an error for the billing_email" do
        valid_checkout.check_matching_billing_email
        expect(valid_checkout.errors[:billing_email]).to be_empty
      end
    end


    context "with a mismatched billing email" do
      it "adds an error for billing_email" do
        _checkout = FactoryGirl.build(:affirm_checkout, billing_email_mismatch: true)
        _checkout.check_matching_billing_email
        expect(_checkout.errors[:billing_email]).not_to be_empty
      end
    end
  end


  describe "check_matching_product_key" do
    context "with a matching product key" do
      it "does not set an error for the financial_product_key" do
        valid_checkout.check_matching_product_key
        expect(valid_checkout.errors[:financial_product_key]).to be_empty
      end
    end


    context "with a mistmatched product key" do
      it "adds an error for financial_product_key" do
        _checkout = FactoryGirl.build(:affirm_checkout, product_key_mismatch: true)
        _checkout.check_matching_product_key
        expect(_checkout.errors[:financial_product_key]).not_to be_empty
      end
    end
  end



  describe "actions" do

    describe "#actions" do
      it "returns capture, void, and credit" do
        expect(valid_checkout.actions).to eq(['capture', 'void', 'credit'])
      end
    end


    describe "can_capture?" do
      context "with a payment response code set" do
        before(:each) { affirm_payment.response_code = "1234-1234" }

        context "with a payment in pending state" do
          before(:each) { affirm_payment.state = 'pending' }

          it "returns true" do
            expect(valid_checkout.can_capture?(affirm_payment)).to be(true)
          end
        end


        context "with a payment in checkout state" do
          before(:each) { affirm_payment.state = 'checkout' }

          it "returns true" do
            expect(valid_checkout.can_capture?(affirm_payment)).to be(true)
          end
        end


        context "with a payment in complete state" do
          before(:each) { affirm_payment.state = 'complete' }

          it "returns false" do
            expect(valid_checkout.can_capture?(affirm_payment)).to be(false)
          end
        end

      end


      context "with no response code set on the payment" do
        before(:each) { affirm_payment.response_code = nil }

        it "returns false" do
          expect(valid_checkout.can_capture?(affirm_payment)).to be(false)
        end
      end
    end


    describe "can_void?" do
      context "with a payment response code set" do
        before(:each) { affirm_payment.response_code = "1234-1234" }

        context "with a payment in pending state" do
          before(:each) { affirm_payment.state = 'pending' }

          it "returns true" do
            expect(valid_checkout.can_void?(affirm_payment)).to be(true)
          end
        end

        context "with a payment in checkout state" do
          before(:each) { affirm_payment.state = 'checkout' }

          it "returns false" do
            expect(valid_checkout.can_void?(affirm_payment)).to be(false)
          end
        end


        context "with a payment in complete state" do
          before(:each) { affirm_payment.state = 'complete' }

          it "returns false" do
            expect(valid_checkout.can_void?(affirm_payment)).to be(false)
          end
        end
      end


      context "with no response code set on the payment" do
        before(:each) { affirm_payment.response_code = nil }

        it "returns false" do
          expect(valid_checkout.can_void?(affirm_payment)).to be(false)
        end
      end
    end



    describe "can_credit?" do
      context "when the payment has not been completed" do
        before(:each) { affirm_payment.state = 'pending' }

        it "returns false" do
          expect(valid_checkout.can_credit?(affirm_payment)).to be(false)
        end
      end

      context "when the payment's order state is not 'credit_owed'" do
        before(:each) do
          affirm_payment.state = 'completed'
          affirm_payment.order.payment_state = 'completed'
        end

        it "returns false" do
          expect(valid_checkout.can_credit?(affirm_payment)).to be(false)
        end
      end

      context "when the payement's order state is 'credit_owed'" do
        before(:each) { affirm_payment.order.payment_state = 'credit_owed' }

        context "when the payment has been completed" do
          before(:each) { affirm_payment.state = 'completed'}

          context "when the payment credit_allowed is greater than 0" do
            before(:each) do
              affirm_payment.stub(:credit_allowed).and_return 100
            end

            it "returns true" do
              expect(valid_checkout.can_credit?(affirm_payment)).to be(true)
            end
          end


          context "when the payment credit_allowed is equal to 0" do
            before(:each) do
              affirm_payment.stub(:credit_allowed).and_return 0
            end

            it "returns false" do
              expect(valid_checkout.can_credit?(affirm_payment)).to be(false)
            end
          end
        end
      end

    end
  end
end
