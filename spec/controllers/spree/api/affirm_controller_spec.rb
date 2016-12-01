require 'spec_helper'

module Spree
  describe Api::AffirmController, type: :controller do
    render_views

    before do
      stub_authentication!
    end

    describe "#payload" do
      it "renders the correct Affirm json payload" do
        get :payload, format: :json
        expect(response).to be_success
      end
    end
  end
end