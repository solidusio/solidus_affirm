require 'spec_helper'

RSpec.describe AffirmHelper do
  describe "#affirm_payload_json" do
    let(:shipping_address) { create(:ship_address, firstname: "John's", lastname: "Do", zipcode: "52106-9133") }
    let(:order) do
      create(:order_with_line_items, ship_address: shipping_address)
    end
    let(:payment_method) { create(:affirm_payment_gateway) }
    let(:metadata) { {} }

    it "calls the configured payload serializer" do
      expect(SolidusAffirm::Config.checkout_payload_serializer).to receive(:new)
      helper.affirm_payload_json(order, payment_method, metadata)
    end

    # regression spec for https://github.com/solidusio/solidus_affirm/issues/42
    it "returns valid JSON with quotes" do
      expect(helper.affirm_payload_json(order, payment_method, metadata)).to include "'"
    end
  end
end
