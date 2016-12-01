require 'spec_helper'

module Spree
  describe Api::AffirmController, type: :controller do
    render_views

    let(:user) { create(:user) }
    let(:current_api_user) { user }
    let(:order) { create(:order_ready_to_complete, user: user) }

    before do
      stub_authentication!
    end

    describe "#payload" do
      subject { get :payload, format: :json }

      before { allow(controller).to receive(:current_order) { order } }

      it "will render the jbuilder json template" do
        expect(subject).to render_template("api/affirm/payload")
      end

      it "renders the correct Affirm json payload" do
        subject
        expect(response).to be_success
        expect(json_response).to_not be_empty

        expect(json_response.key?("merchant")).to be_truthy
        expect(json_response.key?("shipping")).to be_truthy
        expect(json_response.key?("billing")).to be_truthy
        expect(json_response.key?("items")).to be_truthy

        expect(json_response["currency"]).to eql "USD"
        expect(json_response["order_id"]).to eql order.number
        expect(json_response["shipping_amount"]).to eql order.shipment_total.to_money.cents
        expect(json_response["tax_amount"]).to eql order.tax_total.to_money.cents
        expect(json_response["total"]).to eql order.order_total_after_store_credit.to_money.cents
      end
    end
  end
end
