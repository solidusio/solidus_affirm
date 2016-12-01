require 'spec_helper'

module Spree
  describe Api::AffirmController, type: :controller do
    render_views
    describe "#payload" do
      it "renders the correct Affirm json payload" do
        get :payload
      end
    end
  end
end
