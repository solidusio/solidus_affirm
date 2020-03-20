require 'spec_helper'

RSpec.describe "payment/affirm" do
  let(:payment_method) { create(:affirm_payment_gateway) }
  let(:address) { create(:address, firstname: "John's", lastname: "D'o", zipcode: "58451") }
  let(:order) { create(:order_with_totals, shipping_address: address) }

  before do
    allow(view).to receive_messages current_order: order
    allow(view).to receive_messages payment_method: payment_method
  end

  it "renders valid json in html5 data attribute" do
    render partial: "spree/checkout/payment/affirm"
    rendered_partial = Nokogiri::HTML.fragment(rendered)
    affirm_data_attribute = rendered_partial.css('div#affirm_checkout_payload')[0]["data-affirm"]
    expect(affirm_data_attribute).to be_present
    json = JSON.parse(affirm_data_attribute)
    expect(json["shipping"]["name"]).to eql({"first"=>"John's", "last"=>"D'o"})
  end
end
