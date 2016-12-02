require 'spec_helper'

describe Spree::AffirmController, type: :controller do
  let(:user) { create(:user) }
  let(:checkout) { build(:affirm_checkout) }

  describe "POST confirm" do
    def post_request(token, payment_id)
      post :confirm, checkout_token: token, payment_method_id: payment_id, use_route: 'spree'
    end

    before do
      controller.stub authenticate_spree_user!: true
      controller.stub spree_current_user: user
    end

    context "when the checkout matches the order" do
      before do
        Spree::AffirmCheckout.stub new: checkout
        controller.stub current_order: checkout.order
      end

      context "when no checkout_token is provided" do
        it "redirects to the current order state" do
          post_request(nil, nil)
          expect(response).to redirect_to(controller.checkout_state_path(checkout.order.state))
        end
      end

      context "when the order is complete" do
        before do
          checkout.order.state = 'complete'
        end
        it "redirects to the current order state" do
          post_request '123456789', checkout.payment_method.id
          expect(response).to redirect_to(controller.order_path(checkout.order))
        end
      end

      context "when the order state is payment" do
        before do
          checkout.order.state = 'payment'
        end

        it "creates a new payment" do
          post_request "123423423", checkout.payment_method.id

          expect(checkout.order.payments.first.source).to eq(checkout)
        end

        it "transitions to confirm if confirmation is required" do
          checkout.order.stub confirmation_required?: true
          post_request "123423423", checkout.payment_method.id

          expect(checkout.order.reload.state).to eq("confirm")
        end
      end
    end

    context "there is no current order" do
      before(:each) do
        controller.stub current_order: nil
      end

      it "raises an ActiveRecord::RecordNotFound error" do
        expect do
          post_request nil, nil
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
