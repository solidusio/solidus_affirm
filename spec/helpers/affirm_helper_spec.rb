require 'spec_helper'

RSpec.describe AffirmHelper do
  describe "#affirm_payload_json" do
    let(:order) { create(:order) }
    let(:payment_method) { create(:affirm_payment_gateway) }
    let(:metadata) { {} }

    it "calls the configured payload serializer" do
      expect(SolidusAffirm::Config.checkout_payload_serializer).to receive(:new)
      helper.affirm_payload_json(order, payment_method, metadata)
    end
  end
end
