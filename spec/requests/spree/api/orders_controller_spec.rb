require 'spec_helper'

describe Spree::Api::OrdersController, type: :request do
  describe 'get show' do
    let(:user) do
      user = order.user
      user.generate_spree_api_key!
      user
    end

    context 'can render the payment source view for each gateway' do
      before do
        get spree.api_order_path(order, token: user.spree_api_key)
      end

      context "for affrim payment" do
        let!(:order) { create(:order_ready_to_ship, payment_type: :captured_affirm_payment) }

        it "can render" do
          expect(response).to render_template partial: 'spree/api/payments/source_views/_affirm'
        end
      end
    end
  end
end
