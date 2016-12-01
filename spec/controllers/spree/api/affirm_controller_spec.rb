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

      xit "renders the correct Affirm json payload" do
        subject
        expect(response).to be_success
        expect(response.body).to_not be_empty
      end
    end
  end
end
